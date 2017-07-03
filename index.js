'use strict';
const PORT = process.env.PORT || 80;
const awsIot = require('aws-iot-device-sdk');
const bodyParser = require('body-parser');
const app = require('express')();

app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true
  })
);

app.use(function(err, req, res, next) {
  res.status(500).send({ error: err });
});

const device = awsIot.device({
  privateKey: new Buffer(process.env.AWS_PRIVATE_KEY, 'base64'),
  clientCert: new Buffer(process.env.AWS_CERT, 'base64'),
  caCert: new Buffer(process.env.AWS_ROOT_CA, 'base64'),
  clientId: process.env.RESIN_DEVICE_UUID,
  region: process.env.AWS_REGION
});

device.on('connect', () => {
  console.log('device connected to AWS');
});

app.post('/api/publish/:topic', (req, res, next) => {
  if (typeof req.body !== 'object') {
    next(new Error('Topic payload must be an Object'));
  }

  const data = Object.assign(
    {
      gateway: {
        uuid: process.env.RESIN_DEVICE_UUID,
        name: process.env.RESIN_DEVICE_NAME_AT_INIT
      }
    },
    req.body
  );

  console.log(`Publishing ${JSON.stringify(data)}`);
  device.publish(req.params.topic, JSON.stringify(data), null, err => {
    if (err) next(err);
    res.sendStatus(200);
  });
});

app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
});
