import 'package:flutter/material.dart';

class Marche {
  final String id;
  final String reference;
  final String intitule;
  final String description;
  final String typeMarche; // Fourniture, Service, Travaux, etc.
  final String categorie; // Public, Privé, Mixte
  final String statut; // En cours, Clôturé, Attribué, Annulé
  final DateTime dateLancement;
  final DateTime dateLimiteSoumission;
  final DateTime? dateAttribution;
  final DateTime? dateDebut;
  final DateTime? dateFinPrevue;
  final double montantEstime;
  final String devise;
  final String maitreOuvrage;
  final String maitreOuvrageDelegue;
  final String lieuExecution;
  final String dureeGarantie;
  final List<String> documents;
  final String createurId;
  final DateTime dateCreation;
  final DateTime? dateModification;
  final List<Soumission> soumissions;
  final List<Lot> lots;
  final List<DocumentMarche> piecesJointes;
  final String modePassation; // Appel d'offres, Marché de gré à gré, etc.
  final String procedure; // Ouvert, Restreint, etc.
  final String sourceFinancement;
  final String observation;
  final bool estRenouvelable;
  final int dureeContrat; // en mois
  final List<String> motsCles;

  Marche({
    required this.id,
    required this.reference,
    required this.intitule,
    required this.description,
    required this.typeMarche,
    required this.categorie,
    required this.statut,
    required this.dateLancement,
    required this.dateLimiteSoumission,
    this.dateAttribution,
    this.dateDebut,
    this.dateFinPrevue,
    required this.montantEstime,
    this.devise = 'FCFA',
    required this.maitreOuvrage,
    this.maitreOuvrageDelegue = '',
    required this.lieuExecution,
    this.dureeGarantie = '12 mois',
    List<String>? documents,
    required this.createurId,
    required this.dateCreation,
    this.dateModification,
    List<Soumission>? soumissions,
    List<Lot>? lots,
    List<DocumentMarche>? piecesJointes,
    this.modePassation = 'Appel d\'offres',
    this.procedure = 'Ouvert',
    this.sourceFinancement = 'Budget propre',
    this.observation = '',
    this.estRenouvelable = false,
    this.dureeContrat = 12,
    List<String>? motsCles,
  })  : documents = documents ?? [],
        soumissions = soumissions ?? [],
        lots = lots ?? [],
        piecesJointes = piecesJointes ?? [],
        motsCles = motsCles ?? [];

  // Convertir en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'intitule': intitule,
      'description': description,
      'typeMarche': typeMarche,
      'categorie': categorie,
      'statut': statut,
      'dateLancement': dateLancement.toIso8601String(),
      'dateLimiteSoumission': dateLimiteSoumission.toIso8601String(),
      'dateAttribution': dateAttribution?.toIso8601String(),
      'dateDebut': dateDebut?.toIso8601String(),
      'dateFinPrevue': dateFinPrevue?.toIso8601String(),
      'montantEstime': montantEstime,
      'devise': devise,
      'maitreOuvrage': maitreOuvrage,
      'maitreOuvrageDelegue': maitreOuvrageDelegue,
      'lieuExecution': lieuExecution,
      'dureeGarantie': dureeGarantie,
      'documents': documents,
      'createurId': createurId,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
      'soumissions': soumissions.map((s) => s.toJson()).toList(),
      'lots': lots.map((l) => l.toJson()).toList(),
      'piecesJointes': piecesJointes.map((p) => p.toJson()).toList(),
      'modePassation': modePassation,
      'procedure': procedure,
      'sourceFinancement': sourceFinancement,
      'observation': observation,
      'estRenouvelable': estRenouvelable,
      'dureeContrat': dureeContrat,
      'motsCles': motsCles,
    };
  }

  // Créer un marché à partir d'un Map
  factory Marche.fromJson(Map<String, dynamic> json) {
    return Marche(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      intitule: json['intitule'] ?? '',
      description: json['description'] ?? '',
      typeMarche: json['typeMarche'] ?? 'Fourniture',
      categorie: json['categorie'] ?? 'Public',
      statut: json['statut'] ?? 'En cours',
      dateLancement: json['dateLancement'] != null
          ? DateTime.parse(json['dateLancement'])
          : DateTime.now(),
      dateLimiteSoumission: json['dateLimiteSoumission'] != null
          ? DateTime.parse(json['dateLimiteSoumission'])
          : DateTime.now().add(const Duration(days: 30)),
      dateAttribution: json['dateAttribution'] != null
          ? DateTime.parse(json['dateAttribution'])
          : null,
      dateDebut:
          json['dateDebut'] != null ? DateTime.parse(json['dateDebut']) : null,
      dateFinPrevue: json['dateFinPrevue'] != null
          ? DateTime.parse(json['dateFinPrevue'])
          : null,
      montantEstime: (json['montantEstime'] ?? 0).toDouble(),
      devise: json['devise'] ?? 'FCFA',
      maitreOuvrage: json['maitreOuvrage'] ?? '',
      maitreOuvrageDelegue: json['maitreOuvrageDelegue'] ?? '',
      lieuExecution: json['lieuExecution'] ?? '',
      dureeGarantie: json['dureeGarantie'] ?? '12 mois',
      documents: List<String>.from(json['documents'] ?? []),
      createurId: json['createurId'] ?? '',
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
      dateModification: json['dateModification'] != null
          ? DateTime.parse(json['dateModification'])
          : null,
      soumissions: json['soumissions'] != null
          ? (json['soumissions'] as List)
              .map((s) => Soumission.fromJson(s))
              .toList()
          : [],
      lots: json['lots'] != null
          ? (json['lots'] as List).map((l) => Lot.fromJson(l)).toList()
          : [],
      piecesJointes: json['piecesJointes'] != null
          ? (json['piecesJointes'] as List)
              .map((p) => DocumentMarche.fromJson(p))
              .toList()
          : [],
      modePassation: json['modePassation'] ?? 'Appel d\'offres',
      procedure: json['procedure'] ?? 'Ouvert',
      sourceFinancement: json['sourceFinancement'] ?? 'Budget propre',
      observation: json['observation'] ?? '',
      estRenouvelable: json['estRenouvelable'] ?? false,
      dureeContrat: json['dureeContrat'] ?? 12,
      motsCles: List<String>.from(json['motsCles'] ?? []),
    );
  }

  // Copier avec des mises à jour
  Marche copyWith({
    String? id,
    String? reference,
    String? intitule,
    String? description,
    String? typeMarche,
    String? categorie,
    String? statut,
    DateTime? dateLancement,
    DateTime? dateLimiteSoumission,
    DateTime? dateAttribution,
    DateTime? dateDebut,
    DateTime? dateFinPrevue,
    double? montantEstime,
    String? devise,
    String? maitreOuvrage,
    String? maitreOuvrageDelegue,
    String? lieuExecution,
    String? dureeGarantie,
    List<String>? documents,
    String? createurId,
    DateTime? dateCreation,
    DateTime? dateModification,
    List<Soumission>? soumissions,
    List<Lot>? lots,
    List<DocumentMarche>? piecesJointes,
    String? modePassation,
    String? procedure,
    String? sourceFinancement,
    String? observation,
    bool? estRenouvelable,
    int? dureeContrat,
    List<String>? motsCles,
  }) {
    return Marche(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      intitule: intitule ?? this.intitule,
      description: description ?? this.description,
      typeMarche: typeMarche ?? this.typeMarche,
      categorie: categorie ?? this.categorie,
      statut: statut ?? this.statut,
      dateLancement: dateLancement ?? this.dateLancement,
      dateLimiteSoumission: dateLimiteSoumission ?? this.dateLimiteSoumission,
      dateAttribution: dateAttribution ?? this.dateAttribution,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFinPrevue: dateFinPrevue ?? this.dateFinPrevue,
      montantEstime: montantEstime ?? this.montantEstime,
      devise: devise ?? this.devise,
      maitreOuvrage: maitreOuvrage ?? this.maitreOuvrage,
      maitreOuvrageDelegue: maitreOuvrageDelegue ?? this.maitreOuvrageDelegue,
      lieuExecution: lieuExecution ?? this.lieuExecution,
      dureeGarantie: dureeGarantie ?? this.dureeGarantie,
      documents: documents ?? this.documents,
      createurId: createurId ?? this.createurId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      soumissions: soumissions ?? this.soumissions,
      lots: lots ?? this.lots,
      piecesJointes: piecesJointes ?? this.piecesJointes,
      modePassation: modePassation ?? this.modePassation,
      procedure: procedure ?? this.procedure,
      sourceFinancement: sourceFinancement ?? this.sourceFinancement,
      observation: observation ?? this.observation,
      estRenouvelable: estRenouvelable ?? this.estRenouvelable,
      dureeContrat: dureeContrat ?? this.dureeContrat,
      motsCles: motsCles ?? this.motsCles,
    );
  }

  // Vérifier si le marché est clôturé
  bool get estCloture =>
      statut.toLowerCase() == 'clôturé' ||
      statut.toLowerCase() == 'attribué' ||
      statut.toLowerCase() == 'annulé';

  // Vérifier si la date limite de soumission est dépassée
  bool get estEnRetard =>
      !estCloture && dateLimiteSoumission.isBefore(DateTime.now());

  // Obtenir la couleur en fonction du statut
  Color get couleurStatut {
    switch (statut.toLowerCase()) {
      case 'en cours':
        return Colors.blue;
      case 'clôturé':
        return Colors.orange;
      case 'attribué':
        return Colors.green;
      case 'annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Obtenir l'icône en fonction du type de marché
  IconData get iconeTypeMarche {
    switch (typeMarche.toLowerCase()) {
      case 'fourniture':
        return Icons.inventory_2_outlined;
      case 'service':
        return Icons.engineering_outlined;
      case 'travaux':
        return Icons.construction_outlined;
      case 'étude':
        return Icons.analytics_outlined;
      default:
        return Icons.business_center_outlined;
    }
  }

  // Obtenir le nombre de soumissions
  int get nombreSoumissions => soumissions.length;

  // Obtenir le montant total des offres reçues
  double get montantTotalSoumissions {
    if (soumissions.isEmpty) return 0.0;
    return soumissions
        .map((s) => s.montantPropose)
        .reduce((a, b) => a + b);
  }
}

// Classe pour représenter une soumission à un marché
class Soumission {
  final String id;
  final String soumissionnaireId;
  final String soumissionnaireNom;
  final DateTime dateSoumission;
  final double montantPropose;
  final String devise;
  final String statut; // En attente, Sélectionnée, Rejetée
  final String observation;
  final List<DocumentMarche> piecesJointes;
  final Map<String, dynamic> detailsOffre;
  final String modePaiement;
  final String delaiLivraison;
  final String garantieOfferte;

  Soumission({
    required this.id,
    required this.soumissionnaireId,
    required this.soumissionnaireNom,
    required this.dateSoumission,
    required this.montantPropose,
    this.devise = 'FCFA',
    this.statut = 'En attente',
    this.observation = '',
    List<DocumentMarche>? piecesJointes,
    Map<String, dynamic>? detailsOffre,
    this.modePaiement = 'Virement bancaire',
    this.delaiLivraison = '30 jours',
    this.garantieOfferte = '12 mois',
  })  : piecesJointes = piecesJointes ?? [],
        detailsOffre = detailsOffre ?? {};

  // Convertir en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soumissionnaireId': soumissionnaireId,
      'soumissionnaireNom': soumissionnaireNom,
      'dateSoumission': dateSoumission.toIso8601String(),
      'montantPropose': montantPropose,
      'devise': devise,
      'statut': statut,
      'observation': observation,
      'piecesJointes': piecesJointes.map((p) => p.toJson()).toList(),
      'detailsOffre': detailsOffre,
      'modePaiement': modePaiement,
      'delaiLivraison': delaiLivraison,
      'garantieOfferte': garantieOfferte,
    };
  }

  // Créer une soumission à partir d'un Map
  factory Soumission.fromJson(Map<String, dynamic> json) {
    return Soumission(
      id: json['id'] ?? '',
      soumissionnaireId: json['soumissionnaireId'] ?? '',
      soumissionnaireNom: json['soumissionnaireNom'] ?? 'Soumissionnaire inconnu',
      dateSoumission: json['dateSoumission'] != null
          ? DateTime.parse(json['dateSoumission'])
          : DateTime.now(),
      montantPropose: (json['montantPropose'] ?? 0).toDouble(),
      devise: json['devise'] ?? 'FCFA',
      statut: json['statut'] ?? 'En attente',
      observation: json['observation'] ?? '',
      piecesJointes: json['piecesJointes'] != null
          ? (json['piecesJointes'] as List)
              .map((p) => DocumentMarche.fromJson(p))
              .toList()
          : [],
      detailsOffre: Map<String, dynamic>.from(json['detailsOffre'] ?? {}),
      modePaiement: json['modePaiement'] ?? 'Virement bancaire',
      delaiLivraison: json['delaiLivraison'] ?? '30 jours',
      garantieOfferte: json['garantieOfferte'] ?? '12 mois',
    );
  }

  // Obtenir la couleur en fonction du statut
  Color get couleurStatut {
    switch (statut.toLowerCase()) {
      case 'sélectionnée':
        return Colors.green;
      case 'rejetée':
        return Colors.red;
      case 'en attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// Classe pour représenter un lot dans un marché
class Lot {
  final String id;
  final String reference;
  final String intitule;
  final String description;
  final double montantEstime;
  final String devise;
  final String statut; // En attente, Attribué, Non attribué
  final String? attributaireId;
  final String? attributaireNom;
  final double? montantAttribue;
  final DateTime? dateAttribution;
  final List<String> criteresAttribution;
  final List<DocumentMarche> documents;

  Lot({
    required this.id,
    required this.reference,
    required this.intitule,
    required this.description,
    required this.montantEstime,
    this.devise = 'FCFA',
    this.statut = 'En attente',
    this.attributaireId,
    this.attributaireNom,
    this.montantAttribue,
    this.dateAttribution,
    List<String>? criteresAttribution,
    List<DocumentMarche>? documents,
  })  : criteresAttribution = criteresAttribution ?? [],
        documents = documents ?? [];

  // Convertir en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'intitule': intitule,
      'description': description,
      'montantEstime': montantEstime,
      'devise': devise,
      'statut': statut,
      'attributaireId': attributaireId,
      'attributaireNom': attributaireNom,
      'montantAttribue': montantAttribue,
      'dateAttribution': dateAttribution?.toIso8601String(),
      'criteresAttribution': criteresAttribution,
      'documents': documents.map((d) => d.toJson()).toList(),
    };
  }

  // Créer un lot à partir d'un Map
  factory Lot.fromJson(Map<String, dynamic> json) {
    return Lot(
      id: json['id'] ?? '',
      reference: json['reference'] ?? '',
      intitule: json['intitule'] ?? '',
      description: json['description'] ?? '',
      montantEstime: (json['montantEstime'] ?? 0).toDouble(),
      devise: json['devise'] ?? 'FCFA',
      statut: json['statut'] ?? 'En attente',
      attributaireId: json['attributaireId'],
      attributaireNom: json['attributaireNom'],
      montantAttribue: (json['montantAttribue'] ?? 0).toDouble(),
      dateAttribution: json['dateAttribution'] != null
          ? DateTime.parse(json['dateAttribution'])
          : null,
      criteresAttribution:
          List<String>.from(json['criteresAttribution'] ?? []),
      documents: json['documents'] != null
          ? (json['documents'] as List)
              .map((d) => DocumentMarche.fromJson(d))
              .toList()
          : [],
    );
  }

  // Vérifier si le lot est attribué
  bool get estAttribue => statut.toLowerCase() == 'attribué';

  // Obtenir la couleur en fonction du statut
  Color get couleurStatut {
    switch (statut.toLowerCase()) {
      case 'attribué':
        return Colors.green;
      case 'non attribué':
        return Colors.red;
      case 'en attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// Classe pour représenter un document lié à un marché
class DocumentMarche {
  final String id;
  final String nom;
  final String url;
  final String type; // PDF, DOC, XLS, etc.
  final int taille; // en octets
  final DateTime dateUpload;
  final String uploadPar;
  final String description;

  DocumentMarche({
    required this.id,
    required this.nom,
    required this.url,
    required this.type,
    required this.taille,
    required this.dateUpload,
    required this.uploadPar,
    this.description = '',
  });

  // Convertir en Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'url': url,
      'type': type,
      'taille': taille,
      'dateUpload': dateUpload.toIso8601String(),
      'uploadPar': uploadPar,
      'description': description,
    };
  }

  // Créer un document à partir d'un Map
  factory DocumentMarche.fromJson(Map<String, dynamic> json) {
    return DocumentMarche(
      id: json['id'] ?? '',
      nom: json['nom'] ?? 'Document sans nom',
      url: json['url'] ?? '',
      type: json['type'] ?? 'PDF',
      taille: json['taille'] ?? 0,
      dateUpload: json['dateUpload'] != null
          ? DateTime.parse(json['dateUpload'])
          : DateTime.now(),
      uploadPar: json['uploadPar'] ?? 'Utilisateur inconnu',
      description: json['description'] ?? '',
    );
  }

  // Obtenir l'icône en fonction du type de document
  IconData get iconeType {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Formater la taille pour l'affichage
  String get tailleFormatee {
    if (taille < 1024) {
      return '$taille o';
    } else if (taille < 1024 * 1024) {
      return '${(taille / 1024).toStringAsFixed(1)} Ko';
    } else {
      return '${(taille / (1024 * 1024)).toStringAsFixed(1)} Mo';
    }
  }
}
