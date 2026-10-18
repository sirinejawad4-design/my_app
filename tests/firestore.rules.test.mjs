import { readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';

import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';

import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  runTransaction,
  serverTimestamp,
} from 'firebase/firestore';

const projectId = 'doctor-hunt-app-2026';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      host: '127.0.0.1',
      port: 8085,
      rules: readFileSync('firestore.rules', 'utf8'),
    },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv?.cleanup();
});

test('Unauthenticated users cannot read doctors', async () => {
  const db = testEnv.unauthenticatedContext().firestore();

  await assertFails(
    getDoc(doc(db, 'doctors', 'doctor-1')),
  );
});

test('Signed-in users can read doctors', async () => {
  const db = testEnv.authenticatedContext('patient-1').firestore();

  await assertSucceeds(
    getDoc(doc(db, 'doctors', 'doctor-1')),
  );
});

test('Users can read their own profile', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users', 'patient-1'), {
      id: 'patient-1',
      role: 'patient',
      name: 'Test Patient',
    });
  });

  const db = testEnv.authenticatedContext('patient-1').firestore();

  await assertSucceeds(
    getDoc(doc(db, 'users', 'patient-1')),
  );
});

test('Users cannot read another user profile', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users', 'patient-2'), {
      id: 'patient-2',
      role: 'patient',
      name: 'Another Patient',
    });
  });

  const db = testEnv.authenticatedContext('patient-1').firestore();

  await assertFails(
    getDoc(doc(db, 'users', 'patient-2')),
  );
});
test('Users cannot read another patient appointment', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), 'appointments', 'appointment-1'),
      {
        userId: 'patient-2',
        doctorId: 'doctor-1',
        status: 'completed',
        slotId: 'slot-1',
        rated: false,
      },
    );
  });

  const db = testEnv.authenticatedContext('patient-1').firestore();

  await assertFails(
    getDoc(doc(db, 'appointments', 'appointment-1')),
  );
});

test('Users cannot cancel another patient appointment', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), 'appointments', 'appointment-2'),
      {
        userId: 'patient-2',
        doctorId: 'doctor-1',
        status: 'upcoming',
        slotId: 'slot-2',
      },
    );
  });

  const db = testEnv.authenticatedContext('patient-1').firestore();

  await assertFails(
    updateDoc(doc(db, 'appointments', 'appointment-2'), {
      status: 'cancelled',
      cancelledAt: new Date(),
    }),
  );
});

test('Users cannot create a review for another patient appointment', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), 'appointments', 'appointment-3'),
      {
        userId: 'patient-2',
        doctorId: 'doctor-1',
        status: 'completed',
        slotId: 'slot-3',
        rated: false,
      },
    );
  });

  const db = testEnv.authenticatedContext('patient-1').firestore();

  await assertFails(
    setDoc(doc(db, 'reviews', 'appointment-3'), {
      appointmentId: 'appointment-3',
      patientId: 'patient-1',
      doctorId: 'doctor-1',
      rating: 5,
      comment: 'Test review',
    }),
  );
});
test('A patient cannot rate an appointment twice', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), 'appointments', 'rated-appointment'),
      {
        userId: 'patient-1',
        doctorId: 'doctor-1',
        status: 'completed',
        slotId: 'slot-1',
        rated: true,
        rating: 5,
      },
    );
  });

  const db = testEnv.authenticatedContext('patient-1').firestore();

  await assertFails(
    updateDoc(doc(db, 'appointments', 'rated-appointment'), {
      rated: false,
    }),
  );
});
test('A patient cannot rate an appointment without creating its review', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), 'appointments', 'appointment-no-review'),
      {
        userId: 'patient-1',
        doctorId: 'doctor-1',
        status: 'completed',
        slotId: 'slot-1',
        rated: false,
      },
    );
  });

  const db = testEnv.authenticatedContext('patient-1').firestore();

  await assertFails(
    updateDoc(doc(db, 'appointments', 'appointment-no-review'), {
      rated: true,
      rating: 5,
      ratedAt: new Date(),
    }),
  );
});
test('A patient can successfully rate a completed appointment', async () => {
  const appointmentId = 'appointment-valid-review';

  // Prepare test data without applying security rules.
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, 'appointments', appointmentId), {
      userId: 'patient-1',
      doctorId: 'doctor-1',
      status: 'completed',
      slotId: 'slot-1',
      rated: false,
    });

    await setDoc(doc(db, 'doctors', 'doctor-1'), {
      rating: 4,
      reviewsCount: 1,
    });
  });

  const db = testEnv.authenticatedContext('patient-1').firestore();

  const appointmentRef = doc(db, 'appointments', appointmentId);
  const doctorRef = doc(db, 'doctors', 'doctor-1');
  const reviewRef = doc(db, 'reviews', appointmentId);

  await assertSucceeds(
    runTransaction(db, async (transaction) => {
      const appointmentSnapshot = await transaction.get(appointmentRef);
      const doctorSnapshot = await transaction.get(doctorRef);

      assert.equal(appointmentSnapshot.exists(), true);
      assert.equal(doctorSnapshot.exists(), true);

      const rating = 2;
      const oldRating = doctorSnapshot.data().rating;
      const oldCount = doctorSnapshot.data().reviewsCount;
      const newCount = oldCount + 1;

      const newAverage =
        (oldRating * oldCount + rating) / newCount;

      transaction.set(reviewRef, {
        appointmentId,
        patientId: 'patient-1',
        doctorId: 'doctor-1',
        rating,
        comment: 'Test review',
        createdAt: serverTimestamp(),
      });

      transaction.update(doctorRef, {
        rating: newAverage,
        reviewsCount: newCount,
        lastReviewId: appointmentId,
      });

      transaction.update(appointmentRef, {
        rated: true,
        rating,
        ratedAt: serverTimestamp(),
      });
    }),
  );

  // Verify the three documents after the transaction.
  const appointmentSnapshot = await getDoc(appointmentRef);
  const doctorSnapshot = await getDoc(doctorRef);
  const reviewSnapshot = await getDoc(reviewRef);

  assert.equal(appointmentSnapshot.data().rated, true);
  assert.equal(appointmentSnapshot.data().rating, 2);

  assert.equal(reviewSnapshot.exists(), true);
  assert.equal(reviewSnapshot.data().patientId, 'patient-1');
  assert.equal(reviewSnapshot.data().rating, 2);

  assert.equal(doctorSnapshot.data().rating, 3);
  assert.equal(doctorSnapshot.data().reviewsCount, 2);
  assert.equal(doctorSnapshot.data().lastReviewId, appointmentId);
});