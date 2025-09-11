const { Article, Order, Invoice } = require('../models');
const { validationResult } = require('express-validator');

// Gestion des erreurs de validation
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      errors: errors.array()
    });
  }
  next();
};

// Contrôleurs pour les articles
const articleController = {
  // Créer un nouvel article
  async create(req, res) {
    try {
      const article = await Article.create(req.body);
      res.status(201).json({ success: true, data: article });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  // Récupérer tous les articles
  async findAll(req, res) {
    try {
      const articles = await Article.findAll();
      res.json({ success: true, data: articles });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  // Récupérer un article par son ID
  async findById(req, res) {
    try {
      const article = await Article.findById(req.params.id);
      if (!article) {
        return res.status(404).json({ success: false, message: 'Article non trouvé' });
      }
      res.json({ success: true, data: article });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  // Mettre à jour un article
  async update(req, res) {
    try {
      const updated = await Article.update(req.params.id, req.body);
      if (!updated) {
        return res.status(404).json({ success: false, message: 'Article non trouvé' });
      }
      res.json({ success: true, message: 'Article mis à jour avec succès' });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  // Supprimer un article
  async delete(req, res) {
    try {
      const deleted = await Article.delete(req.params.id);
      if (!deleted) {
        return res.status(404).json({ success: false, message: 'Article non trouvé' });
      }
      res.json({ success: true, message: 'Article supprimé avec succès' });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
};

// Contrôleurs pour les commandes
const orderController = {
  // Créer une nouvelle commande
  async create(req, res) {
    try {
      const order = await Order.create(req.body);
      res.status(201).json({ success: true, data: order });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  // Récupérer toutes les commandes
  async findAll(req, res) {
    try {
      const orders = await Order.findAll();
      res.json({ success: true, data: orders });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  // Mettre à jour le statut d'une commande
  async updateStatus(req, res) {
    try {
      const { status } = req.body;
      const updated = await Order.updateStatus(req.params.id, status);
      if (!updated) {
        return res.status(404).json({ success: false, message: 'Commande non trouvée' });
      }
      res.json({ success: true, message: 'Statut de la commande mis à jour' });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
};

// Contrôleurs pour les factures
const invoiceController = {
  // Créer une nouvelle facture
  async create(req, res) {
    try {
      const invoice = await Invoice.create(req.body);
      res.status(201).json({ success: true, data: invoice });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  // Récupérer toutes les factures
  async findAll(req, res) {
    try {
      const { status } = req.query;
      let invoices;
      
      if (status) {
        invoices = await Invoice.findAll({ where: { status } });
      } else {
        invoices = await Invoice.findAll();
      }
      
      res.json({ success: true, data: invoices });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  },

  // Marquer une facture comme payée
  async markAsPaid(req, res) {
    try {
      const updated = await Invoice.updateStatus(req.params.id, 'paid');
      if (!updated) {
        return res.status(404).json({ success: false, message: 'Facture non trouvée' });
      }
      res.json({ success: true, message: 'Facture marquée comme payée' });
    } catch (error) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
};

module.exports = {
  handleValidationErrors,
  articleController,
  orderController,
  invoiceController
};
