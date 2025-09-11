import 'package:flutter/material.dart';

class Relance {
  final String id;
  final String clientId;
  final String clientNom;
  final String typeRelance; // Email, Appel, SMS, Courrier
  final String objet;
  final String contenu;
  final DateTime dateCreation;
  final DateTime datePlanification;
  final DateTime? dateEnvoi;
  final String statut; // Planifiée, Envoyée, Annulée, Échouée
  final String priorite; // Haute, Moyenne, Basse
  final String createurId;
  final String? assigneA;
  final String? pieceJointeUrl;
  final String? commentaire;
  final String? factureId;
  final double? montantDus;

  Relance({
    required this.id,
    required this.clientId,
    required this.clientNom,
    required this.typeRelance,
    required this.objet,
    required this.contenu,
    required this.dateCreation,
    required this.datePlanification,
    this.dateEnvoi,
    this.statut = 'Planifiée',
    this.priorite = 'Moyenne',
    required this.createurId,
    this.assigneA,
    this.pieceJointeUrl,
    this.commentaire,
    this.factureId,
    this.montantDus,
  });

  // Convertir en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientNom': clientNom,
      'typeRelance': typeRelance,
      'objet': objet,
      'contenu': contenu,
      'dateCreation': dateCreation.toIso8601String(),
      'datePlanification': datePlanification.toIso8601String(),
      'dateEnvoi': dateEnvoi?.toIso8601String(),
      'statut': statut,
      'priorite': priorite,
      'createurId': createurId,
      'assigneA': assigneA,
      'pieceJointeUrl': pieceJointeUrl,
      'commentaire': commentaire,
      'factureId': factureId,
      'montantDus': montantDus,
    };
  }

  // Créer une relance à partir d'un Map
  factory Relance.fromJson(Map<String, dynamic> json) {
    return Relance(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      clientNom: json['clientNom'] ?? 'Client inconnu',
      typeRelance: json['typeRelance'] ?? 'Email',
      objet: json['objet'] ?? 'Sans objet',
      contenu: json['contenu'] ?? '',
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
      datePlanification: json['datePlanification'] != null
          ? DateTime.parse(json['datePlanification'])
          : DateTime.now().add(const Duration(days: 1)),
      dateEnvoi: json['dateEnvoi'] != null ? DateTime.parse(json['dateEnvoi']) : null,
      statut: json['statut'] ?? 'Planifiée',
      priorite: json['priorite'] ?? 'Moyenne',
      createurId: json['createurId'] ?? '',
      assigneA: json['assigneA'],
      pieceJointeUrl: json['pieceJointeUrl'],
      commentaire: json['commentaire'],
      factureId: json['factureId'],
      montantDus: (json['montantDus'] ?? 0).toDouble(),
    );
  }

  // Copier avec des mises à jour
  Relance copyWith({
    String? id,
    String? clientId,
    String? clientNom,
    String? typeRelance,
    String? objet,
    String? contenu,
    DateTime? dateCreation,
    DateTime? datePlanification,
    DateTime? dateEnvoi,
    String? statut,
    String? priorite,
    String? createurId,
    String? assigneA,
    String? pieceJointeUrl,
    String? commentaire,
    String? factureId,
    double? montantDus,
  }) {
    return Relance(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientNom: clientNom ?? this.clientNom,
      typeRelance: typeRelance ?? this.typeRelance,
      objet: objet ?? this.objet,
      contenu: contenu ?? this.contenu,
      dateCreation: dateCreation ?? this.dateCreation,
      datePlanification: datePlanification ?? this.datePlanification,
      dateEnvoi: dateEnvoi ?? this.dateEnvoi,
      statut: statut ?? this.statut,
      priorite: priorite ?? this.priorite,
      createurId: createurId ?? this.createurId,
      assigneA: assigneA ?? this.assigneA,
      pieceJointeUrl: pieceJointeUrl ?? this.pieceJointeUrl,
      commentaire: commentaire ?? this.commentaire,
      factureId: factureId ?? this.factureId,
      montantDus: montantDus ?? this.montantDus,
    );
  }

  // Vérifier si la relance est en retard
  bool get estEnRetard =>
      statut == 'Planifiée' && datePlanification.isBefore(DateTime.now());

  // Obtenir la couleur en fonction du statut
  Color get couleurStatut {
    switch (statut.toLowerCase()) {
      case 'envoyée':
        return Colors.green;
      case 'planifiée':
        return Colors.blue;
      case 'échouée':
        return Colors.red;
      case 'annulée':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  // Obtenir l'icône en fonction du type de relance
  IconData get iconeTypeRelance {
    switch (typeRelance.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'appel':
        return Icons.phone;
      case 'sms':
        return Icons.sms;
      case 'courrier':
        return Icons.mail;
      default:
        return Icons.notifications;
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
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Obtenir le texte d'affichage pour le statut
  String get statutAffichage {
    switch (statut.toLowerCase()) {
      case 'envoyée':
        return 'Envoyée';
      case 'planifiée':
        return 'Planifiée';
      case 'échouée':
        return 'Échouée';
      case 'annulée':
        return 'Annulée';
      default:
        return statut;
    }
  }
}
