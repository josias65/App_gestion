const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const {
  articleController,
  orderController,
  invoiceController,
  handleValidationErrors
} = require('../controllers');

// Middleware d'authentification (à implémenter si nécessaire)
const authenticate = (req, res, next) => {
  // Votre logique d'authentification ici
  next();
};

// Routes pour les articles
router.get('/articles', articleController.findAll);
router.get('/articles/:id', articleController.findById);

// Routes protégées nécessitant une authentification
router.post('/articles', [
  authenticate,
  body('name').notEmpty(),
  body('price').isNumeric(),
  body('quantity').isInt(),
  handleValidationErrors
], articleController.create);

router.put('/articles/:id', [
  authenticate,
  handleValidationErrors
], articleController.update);

router.delete('/articles/:id', authenticate, articleController.delete);

// Routes pour les commandes
router.get('/orders', orderController.findAll);
router.post('/orders', [
  authenticate,
  body('customerId').isInt(),
  body('items').isArray(),
  body('total').isNumeric(),
  handleValidationErrors
], orderController.create);

router.put('/orders/:id/status', [
  authenticate,
  body('status').isIn(['pending', 'processing', 'shipped', 'delivered', 'cancelled']),
  handleValidationErrors
], orderController.updateStatus);

// Routes pour les factures
router.get('/invoices', invoiceController.findAll);
router.post('/invoices', [
  authenticate,
  body('orderId').isInt(),
  body('customerId').isInt(),
  body('amount').isNumeric(),
  body('dueDate').isISO8601(),
  handleValidationErrors
], invoiceController.create);

router.post('/invoices/:id/pay', [
  authenticate
], invoiceController.markAsPaid);

module.exports = router;
