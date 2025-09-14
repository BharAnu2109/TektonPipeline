const request = require('supertest');
const { expect } = require('chai');
const app = require('../app');

describe('Tekton Pipeline Demo App', () => {
  describe('GET /', () => {
    it('should return welcome message', (done) => {
      request(app)
        .get('/')
        .expect(200)
        .end((err, res) => {
          if (err) return done(err);
          expect(res.body).to.have.property('message');
          expect(res.body.message).to.equal('Welcome to Tekton Pipeline Demo!');
          expect(res.body).to.have.property('version');
          done();
        });
    });
  });

  describe('GET /health', () => {
    it('should return health status', (done) => {
      request(app)
        .get('/health')
        .expect(200)
        .end((err, res) => {
          if (err) return done(err);
          expect(res.body).to.have.property('status');
          expect(res.body.status).to.equal('healthy');
          expect(res.body).to.have.property('timestamp');
          expect(res.body).to.have.property('version');
          done();
        });
    });
  });

  describe('GET /api/info', () => {
    it('should return service information', (done) => {
      request(app)
        .get('/api/info')
        .expect(200)
        .end((err, res) => {
          if (err) return done(err);
          expect(res.body).to.have.property('service');
          expect(res.body.service).to.equal('tekton-pipeline-demo');
          expect(res.body).to.have.property('features');
          expect(res.body.features).to.be.an('array');
          done();
        });
    });
  });

  describe('GET /nonexistent', () => {
    it('should return 404 for non-existent routes', (done) => {
      request(app)
        .get('/nonexistent')
        .expect(404)
        .end((err, res) => {
          if (err) return done(err);
          expect(res.body).to.have.property('error');
          expect(res.body.error).to.equal('Route not found');
          done();
        });
    });
  });
});