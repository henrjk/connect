/**
 * Passwordless
 *
 * Signin/Signup by clicking a link send by email.
 */

module.exports = function (config) {
  return {
    id: 'passwordless',
    name: 'Email only',
    protocol: 'Passwordless',
    amr: 'pwd', // TODO: is there a proper amr value for passwordless?
    tokenTTL: 60 * 15,
    fields: [
      { name: 'email', type: 'email' }
    ],
    usernameField: 'email'  // TODO: write test that this is used.
  }
}
