'use strict';
const {onCall, HttpsError} = require('firebase-functions/v2/https');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const {getAuth} = require('firebase-admin/auth');
const {deleteUserData} = require('./deletion');
initializeApp();

exports.deleteMyAccount = onCall({region: 'us-central1', timeoutSeconds: 120, memory: '256MiB'}, async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sessão não autenticada.');
  const authTime = request.auth.token.auth_time;
  const anonymous = request.auth.token.firebase?.sign_in_provider === 'anonymous';
  // Anonymous sessions have no credential to reauthenticate with. Authorization
  // still comes exclusively from the verified token and its own UID.
  if (!anonymous && (typeof authTime !== 'number' || Date.now() / 1000 - authTime > 300)) {
    throw new HttpsError('failed-precondition', 'Confirme sua senha novamente.');
  }
  // UID comes exclusively from the verified Firebase token. Ignore caller data.
  try {
    return await deleteUserData(request.auth.uid, {db: getFirestore(), auth: getAuth()});
  } catch (_) {
    throw new HttpsError('unavailable', 'Exclusão pendente. Conecte-se e tente novamente.');
  }
});
