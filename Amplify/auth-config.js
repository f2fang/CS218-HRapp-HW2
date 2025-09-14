// auth-config.js
// Reuse Cognito + Amplify across pages (Code + PKCE), with "return to previous page" support.

(function () {
  const { Amplify, Auth, Hub } = window.aws_amplify;

  // ====== <<< YOUR SETTINGS >>> ======
  const CONFIG = {
    region: "us-west-1",
    userPoolId: "us-west-1_gPOIMCEDP",
    userPoolWebClientId: "6ea5qbg5cf8lbr5cpp2javetp4", // no client secret
    domain: "hr-auth-14661.auth.us-west-1.amazoncognito.com",
    redirectUrl: "https://staging.d2zq2v1gu1gfsu.amplifyapp.com/",
    scopes: ["openid", "email", "profile"],
    responseType: "code", // Code + PKCE
  };

  function init() {
    Amplify.configure({
      Auth: {
        region: CONFIG.region,
        userPoolId: CONFIG.userPoolId,
        userPoolWebClientId: CONFIG.userPoolWebClientId,
        storage: window.sessionStorage,
        oauth: {
          domain: CONFIG.domain,
          scope: CONFIG.scopes,
          redirectSignIn: CONFIG.redirectUrl,
          redirectSignOut: CONFIG.redirectUrl,
          responseType: CONFIG.responseType,
        },
      },
    });

    // If we just came back from Hosted UI and have a stored returnTo, go there.
    (async () => {
      try {
        await Auth.currentAuthenticatedUser();
        const rt = sessionStorage.getItem("returnTo");
        if (rt) {
          sessionStorage.removeItem("returnTo");
          if (location.href !== rt) location.href = rt;
        }
      } catch { /* not signed in */ }
    })();
  }

  async function isSignedIn() {
    try { await Auth.currentAuthenticatedUser(); return true; }
    catch { return false; }
  }

  function login(returnTo) {
    if (returnTo) sessionStorage.setItem("returnTo", returnTo);
    Auth.federatedSignIn(); // open Hosted UI
  }

  async function logout() {
    // Hard redirect to Hosted UI /logout + clear local/session storage
    try {
      Object.keys(localStorage)
        .filter(k => k.startsWith("CognitoIdentityServiceProvider.") || k.startsWith("aws.cognito.identity-id"))
        .forEach(k => localStorage.removeItem(k));
      sessionStorage.clear();
    } catch {}

    const u = new URL(`https://${CONFIG.domain}/logout`);
    u.searchParams.set("client_id", CONFIG.userPoolWebClientId);
    u.searchParams.set("logout_uri", CONFIG.redirectUrl);
    window.location.assign(u.toString());
  }

  async function getIdToken() {
    const s = await Auth.currentSession();
    return s.getIdToken().getJwtToken();
  }

  async function getAccessToken() {
    const s = await Auth.currentSession();
    return s.getAccessToken().getJwtToken();
  }

  // Get ready-to-use Authorization header
  // opts: { use: 'id' | 'access', bearer: true|false }
  async function getAuthHeader(opts = { use: "id", bearer: true }) {
    const token = opts.use === "access" ? await getAccessToken() : await getIdToken();
    return opts.bearer ? `Bearer ${token}` : token;
  }

  function onAuthChange(cb) {
    Hub.listen("auth", ({ payload }) => {
      if (payload?.event === "signIn")  cb(true);
      if (payload?.event === "signOut") cb(false);
    });
  }

  // Expose
  window.AuthKit = { init, isSignedIn, login, logout, getIdToken, getAccessToken, getAuthHeader, onAuthChange, CONFIG };
})();

