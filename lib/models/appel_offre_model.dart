import 'package:flutter/material.dart';

class AppelOffre {
  final String id;
  final String titre;
  final String description;
  final DateTime dateCreation;
  final DateTime dateLimite;
  final String etat;
  final double budget;
  final String categorie;
  final int nombreSoumissions;
  final bool favori;
  final String urgence;
  final String localisation;
  final List<String> documents;
  final String createurId;
  final DateTime? dateModification;

  AppelOffre({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateCreation,
    required this.dateLimite,
    required this.etat,
    required this.budget,
    required this.categorie,
    this.nombreSoumissions = 0,
    this.favori = false,
    required this.urgence,
    required this.localisation,
    required this.documents,
    required this.createurId,
    this.dateModification,
  });

  // Convertir un appel d'offre en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'dateCreation': dateCreation.toIso8601String(),
      'dateLimite': dateLimite.toIso8601String(),
      'etat': etat,
      'budget': budget,
      'categorie': categorie,
      'nombreSoumissions': nombreSoumissions,
      'favori': favori,
      'urgence': urgence,
      'localisation': localisation,
      'documents': documents,
      'createurId': createurId,
      'dateModification': dateModification?.toIso8601String(),
    };
  }

  // Créer un appel d'offre à partir d'un Map
  factory AppelOffre.fromJson(Map<String, dynamic> json) {
    return AppelOffre(
      id: json['id'] ?? '',
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
      dateLimite: json['dateLimite'] != null
          ? DateTime.parse(json['dateLimite'])
          : DateTime.now().add(const Duration(days: 30)),
      etat: json['etat'] ?? 'Brouillon',
      budget: (json['budget'] ?? 0).toDouble(),
      categorie: json['categorie'] ?? 'Général',
      nombreSoumissions: json['nombreSoumissions'] ?? 0,
      favori: json['favori'] ?? false,
      urgence: json['urgence'] ?? 'Moyenne',
      localisation: json['localisation'] ?? '',
      documents: List<String>.from(json['documents'] ?? []),
      createurId: json['createurId'] ?? '',
      dateModification: json['dateModification'] != null
          ? DateTime.parse(json['dateModification'])
          : null,
    );
  }

  // Copier avec des mises à jour
  AppelOffre copyWith({
    String? id,
    String? titre,
    String? description,
    DateTime? dateCreation,
    DateTime? dateLimite,
    String? etat,
    double? budget,
    String? categorie,
    int? nombreSoumissions,
    bool? favori,
    String? urgence,
    String? localisation,
    List<String>? documents,
    String? createurId,
    DateTime? dateModification,
  }) {
    return AppelOffre(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      dateCreation: dateCreation ?? this.dateCreation,
      dateLimite: dateLimite ?? this.dateLimite,
      etat: etat ?? this.etat,
      budget: budget ?? this.budget,
      categorie: categorie ?? this.categorie,
      nombreSoumissions: nombreSoumissions ?? this.nombreSoumissions,
      favori: favori ?? this.favori,
      urgence: urgence ?? this.urgence,
      localisation: localisation ?? this.localisation,
      documents: documents ?? this.documents,
      createurId: createurId ?? this.createurId,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}

// Énumération pour les états d'un appel d'offre
enum EtatAppelOffre {
  brouillon('Brouillon', Icons.drafts, Colors.grey),
  publie('Publié', Icons.public, Colors.blue),
  enCours('En cours', Icons.hourglass_empty, Colors.orange),
  cloture('Clôturé', Icons.lock_clock, Colors.red),
  attribue('Attribué', Icons.check_circle, Colors.green),
  annule('Annulé', Icons.cancel, Colors.red);

  final String libelle;
  final IconData icone;
  final Color couleur;

  const EtatAppelOffre(this.libelle, this.icone, this.couleur);

  static EtatAppelOffre fromString(String value) {
    return EtatAppelOffre.values.firstWhere(
      (e) => e.libelle.toLowerCase() == value.toLowerCase(),
      orElse: () => EtatAppelOffre.brouillon,
    );
  }
}
