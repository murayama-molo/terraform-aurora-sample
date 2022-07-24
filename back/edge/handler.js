const { Authenticator } = require("cognito-at-edge");

try {
  const ENV = require("dotenv").config();
  console.log("ENV", ENV);
} catch (ex) {
  console.error("ex", ex);
}

console.log("process.env", process.env);

const authenticator = new Authenticator({
  // Replace these parameter values with those of your own environment
  region: process.env.REGION,
  userPoolId: process.env.USER_POOL_ID,
  userPoolAppId: process.env.USER_POOL_APP_ID,
  userPoolDomain: `${process.env.USER_POOL_DOMAIN}.auth.ap-northeast-1.amazoncognito.com`,
});

exports.handler = async (request) => authenticator.handle(request);
