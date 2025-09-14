// GET /hr/{id}?fields=name,salary,dateOfJoin
const AWS = require('aws-sdk');
const ddb = new AWS.DynamoDB.DocumentClient();

const ALLOWED = new Set(['name','salary','dateOfJoin']);
const ORIGIN = process.env.CORS_ORIGIN || '*';
const TABLE  = process.env.TABLE_NAME;

exports.handler = async (event) => {
  try {
    const id = event.pathParameters && event.pathParameters.id;
    const qs = event.queryStringParameters || {};
    if (!id) return resp(400, {message:'Missing id'});

    let fields = (qs.fields || '').split(',').map(s => s.trim()).filter(Boolean);
    if (fields.length === 0) return resp(400, {message:'Select at least one field'});
    if (fields.length > 3)  return resp(400, {message:'Select at most three fields'});
    for (const f of fields) if (!ALLOWED.has(f)) return resp(400, {message:`Invalid field ${f}`});

    const data = await ddb.get({ TableName: TABLE, Key: { id } }).promise();
    if (!data.Item) return resp(404, {message:'Not found'});

    const out = {};
    for (const f of fields) out[f] = data.Item[f];
    return resp(200, out);
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
