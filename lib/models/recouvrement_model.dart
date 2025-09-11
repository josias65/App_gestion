import 'package:flutter/material.dart';

class Recouvrement {
  final String id;
  final String factureId;
  final String clientId;
  final String clientNom;
  final double montantDu;
  final DateTime dateEcheance;
  final String statut;
  final String priorite;
  final String commentaire;
  final String assigneA;
  final DateTime dateCreation;
  final DateTime? dateDernierPaiement;
  final double montantRecouvre;
  final List<PaiementRecouvrement> historiquePaiements;

  Recouvrement({
    required this.id,
    required this.factureId,
    required this.clientId,
    required this.clientNom,
    required this.montantDu,
    required this.dateEcheance,
    this.statut = 'En attente',
    this.priorite = 'Moyenne',
    this.commentaire = '',
    required this.assigneA,
    required this.dateCreation,
    this.dateDernierPaiement,
    this.montantRecouvre = 0.0,
    List<PaiementRecouvrement>? historiquePaiements,
  }) : historiquePaiements = historiquePaiements ?? [];

  // Convertir en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'factureId': factureId,
      'clientId': clientId,
      'clientNom': clientNom,
      'montantDu': montantDu,
      'dateEcheance': dateEcheance.toIso8601String(),
      'statut': statut,
      'priorite': priorite,
      'commentaire': commentaire,
      'assigneA': assigneA,
      'dateCreation': dateCreation.toIso8601String(),
      'dateDernierPaiement': dateDernierPaiement?.toIso8601String(),
      'montantRecouvre': montantRecouvre,
      'historiquePaiements': historiquePaiements.map((p) => p.toJson()).toList(),
    };
  }

  // Créer un recouvrement à partir d'un Map
  factory Recouvrement.fromJson(Map<String, dynamic> json) {
    return Recouvrement(
      id: json['id'] ?? '',
      factureId: json['factureId'] ?? '',
      clientId: json['clientId'] ?? '',
      clientNom: json['clientNom'] ?? 'Client inconnu',
      montantDu: (json['montantDu'] ?? 0).toDouble(),
      dateEcheance: json['dateEcheance'] != null
          ? DateTime.parse(json['dateEcheance'])
          : DateTime.now().add(const Duration(days: 30)),
      statut: json['statut'] ?? 'En attente',
      priorite: json['priorite'] ?? 'Moyenne',
      commentaire: json['commentaire'] ?? '',
      assigneA: json['assigneA'] ?? '',
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
      dateDernierPaiement: json['dateDernierPaiement'] != null
          ? DateTime.parse(json['dateDernierPaiement'])
          : null,
      montantRecouvre: (json['montantRecouvre'] ?? 0).toDouble(),
      historiquePaiements: json['historiquePaiements'] != null
          ? (json['historiquePaiements'] as List)
              .map((p) => PaiementRecouvrement.fromJson(p))
              .toList()
          : [],
    );
  }

  // Copier avec des mises à jour
  Recouvrement copyWith({
    String? id,
    String? factureId,
    String? clientId,
    String? clientNom,
    double? montantDu,
    DateTime? dateEcheance,
    String? statut,
    String? priorite,
    String? commentaire,
    String? assigneA,
    DateTime? dateCreation,
    DateTime? dateDernierPaiement,
    double? montantRecouvre,
    List<PaiementRecouvrement>? historiquePaiements,
  }) {
    return Recouvrement(
      id: id ?? this.id,
      factureId: factureId ?? this.factureId,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      montantDu: montantDu ?? this.montantDu,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      statut: statut ?? this.statut,
      priorite: priorite ?? this.priorite,
      commentaire: commentaire ?? this.commentaire,
      assigneA: assigneA ?? this.assigneA,
      dateCreation: dateCreation ?? this.dateCreation,
      dateDernierPaiement: dateDernierPaiement ?? this.dateDernierPaiement,
      montantRecouvre: montantRecouvre ?? this.montantRecouvre,
      historiquePaiements: historiquePaiements ?? this.historiquePaiements,
    );
  }

  // Calculer le montant restant à recouvrer
  double get montantRestant => montantDu - montantRecouvre;

  // Vérifier si le recouvrement est en retard
  bool get estEnRetard =>
      statut != 'Payé' && dateEcheance.isBefore(DateTime.now());

  // Obtenir la couleur en fonction du statut
  Color get couleurStatut {
    switch (statut.toLowerCase()) {
      case 'payé':
        return Colors.green;
      case 'en cours':
        return Colors.blue;
      case 'en attente':
        return Colors.orange;
      case 'en retard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Obtenir l'icône en fonction de la priorité
  IconData get iconePriorite {
    switch (priorite.toLowerCase()) {
      case 'haute':
        return Icons.warning_amber_rounded;
      case 'moyenne':
        return Icons.priority_high_rounded;
      case 'basse':
        return Icons.low_priority_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Obtenir la couleur en fonction de la priorité
  Color get couleurPriorite {
    switch (priorite.toLowerCase()) {
      case 'haute':
        return Colors.red;
      case 'moyenne':
        return Colors.orange;
      case 'basse':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Classe pour représenter un paiement de recouvrement
class PaiementRecouvrement {
  final String id;
  final DateTime datePaiement;
  final double montant;
  final String modePaiement;
  final String reference;
  final String note;
  final String enregistrePar;

  PaiementRecouvrement({
    required this.id,
    required this.datePaiement,
    required this.montant,
    this.modePaiement = 'Espèces',
    this.reference = '',
    this.note = '',
    required this.enregistrePar,
  });

  // Convertir en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datePaiement': datePaiement.toIso8601String(),
      'montant': montant,
      'modePaiement': modePaiement,
      'reference': reference,
      'note': note,
      'enregistrePar': enregistrePar,
    };
  }

  // Créer un paiement à partir d'un Map
  factory PaiementRecouvrement.fromJson(Map<String, dynamic> json) {
    return PaiementRecouvrement(
      id: json['id'] ?? '',
      datePaiement: json['datePaiement'] != null
          ? DateTime.parse(json['datePaiement'])
          : DateTime.now(),
      montant: (json['montant'] ?? 0).toDouble(),
      modePaiement: json['modePaiement'] ?? 'Espèces',
      reference: json['reference'] ?? '',
      note: json['note'] ?? '',
      enregistrePar: json['enregistrePar'] ?? '',
    );
  }
}
