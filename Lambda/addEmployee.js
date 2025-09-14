// POST /hr  body: {id,name,salary,dateOfJoin}
const AWS = require('aws-sdk');
const ddb = new AWS.DynamoDB.DocumentClient();
const ORIGIN = process.env.CORS_ORIGIN || '*';
const TABLE  = process.env.TABLE_NAME;

exports.handler = async (event) => {
  try {
    const body = event.body ? JSON.parse(event.body) : {};
    const { id, name, salary, dateOfJoin } = body || {};
    if (!id || !name || salary === undefined || !dateOfJoin) {
      return resp(400, {message:'id, name, salary, dateOfJoin are required'});
    }

    await ddb.put({
      TableName: TABLE,
      Item: { id, name, salary: Number(salary), dateOfJoin }
    }).promise();

    return resp(200, { message: 'ok' });
  } catch (e) {
    console.error(e);
    return resp(500, {message:'Internal error'});
  }
};

function resp(code, body) {
  return {
    statusCode: code,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': ORIGIN,
      'Access-Control-Allow-Headers': 'Authorization,Content-Type',
      'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
    },
    body: JSON.stringify(body)
  };
}
