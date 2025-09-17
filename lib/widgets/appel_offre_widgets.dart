import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class AppelOffreCard extends StatelessWidget {
  final Map<String, dynamic> appelOffre;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;

  const AppelOffreCard({
    super.key,
    required this.appelOffre,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onFavorite,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = appelOffre['status']?.toString().toLowerCase() == 'open' ||
                   appelOffre['etat']?.toString().toLowerCase() == 'ouvert';
    
    final budget = appelOffre['budget']?.toString() ?? 'Non spécifié';
    final deadline = appelOffre['deadline'] ?? appelOffre['dateLimite'];
    final category = appelOffre['category'] ?? appelOffre['categorie'] ?? 'Non spécifié';
    final location = appelOffre['location'] ?? appelOffre['localisation'] ?? 'Non spécifié';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isOpen 
              ? LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut et actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(isOpen).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: _getStatusColor(isOpen),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appelOffre['title'] ?? appelOffre['titre'] ?? 'Sans titre',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                        case 'favorite':
                          onFavorite?.call();
                          break;
                        case 'share':
                          onShare?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'favorite',
                        child: Row(
                          children: [
                            Icon(
                              (appelOffre['favorite'] == true) ? Icons.favorite : Icons.favorite_border,
                              color: (appelOffre['favorite'] == true) ? Colors.red : null,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text((appelOffre['favorite'] == true) ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 16),
                            SizedBox(width: 8),
                            Text('Partager'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Statut et budget
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(isOpen),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(isOpen),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatBudget(budget),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F0465),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Description
              if (appelOffre['description'] != null)
                Text(
                  appelOffre['description'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              
              // Informations supplémentaires
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Échéance: ${_formatDate(deadline)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              
              // Nombre de soumissions
              if (appelOffre['soumissions_count'] != null && appelOffre['soumissions_count'] > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 14, color: Colors.blue[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${appelOffre['soumissions_count']} soumission(s)',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(bool isOpen) {
    return isOpen ? const Color(0xFF4CAF50) : Colors.grey;
  }

  String _getStatusText(bool isOpen) {
    return isOpen ? 'OUVERT' : 'FERMÉ';
  }

  String _formatBudget(dynamic budget) {
    if (budget == null) return 'Non spécifié';
    
    final budgetStr = budget.toString();
    if (budgetStr.contains('FCFA')) return budgetStr;
    
    // Si c'est un nombre, le formater
    final budgetNum = double.tryParse(budgetStr);
    if (budgetNum != null) {
      if (budgetNum >= 1000000) {
        return '${(budgetNum / 1000000).toStringAsFixed(1)}M FCFA';
      } else if (budgetNum >= 1000) {
        return '${(budgetNum / 1000).toStringAsFixed(0)}K FCFA';
      } else {
        return '${budgetNum.toStringAsFixed(0)} FCFA';
      }
    }
    
    return budgetStr;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Non spécifié';
    
    final dateStr = date.toString();
    if (dateStr.contains('/')) return dateStr; // Déjà formaté
    
    try {
      final dateTime = DateTime.parse(dateStr);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

class DocumentCard extends StatelessWidget {
  final Map<String, dynamic> document;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    this.onDownload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getFileTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFileTypeIcon(),
            color: _getFileTypeColor(),
            size: 20,
          ),
        ),
        title: Text(
          document['original_name'] ?? document['filename'] ?? 'Document',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatFileSize(document['file_size'])),
            Text(
              _formatDate(document['created_at']),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download, size: 20),
              onPressed: onDownload,
              tooltip: 'Télécharger',
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Supprimer',
              ),
          ],
        ),
      ),
    );
  }

  IconData _getFileTypeIcon() {
    final fileType = document['file_type']?.toString().toLowerCase() ?? '';
    
    if (fileType.contains('pdf')) return Icons.picture_as_pdf;
    if (fileType.contains('word')) return Icons.description;
    if (fileType.contains('excel') || fileType.contains('spreadsheet')) return Icons.table_chart;
    if (fileType.contains('image')) return Icons.image;
    
    return Icons.insert_drive_file;
  }

  Color _getFileTypeColor() {
    final fileType = document['file_type']?.toString().toLowerCase() ?? '';
    
    if (fileType.contains('pdf')) return Colors.red;
    if (fileType.contains('word')) return Colors.blue;
    if (fileType.contains('excel') || fileType.contains('spreadsheet')) return Colors.green;
    if (fileType.contains('image')) return Colors.purple;
    
    return Colors.grey;
  }

  String _formatFileSize(dynamic size) {
    if (size == null) return 'Taille inconnue';
    
    final sizeNum = int.tryParse(size.toString());
    if (sizeNum == null) return 'Taille inconnue';
    
    if (sizeNum >= 1024 * 1024) {
      return '${(sizeNum / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (sizeNum >= 1024) {
      return '${(sizeNum / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$sizeNum B';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return date.toString();
    }
  }
}

class CommentCard extends StatelessWidget {
  final Map<String, dynamic> comment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    (comment['user_name'] ?? 'U')[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['user_name'] ?? 'Utilisateur',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDate(comment['created_at']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment['content'] ?? '',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    
    try {
      final dateTime = DateTime.parse(date.toString());
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} jour(s)';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} heure(s)';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute(s)';
      } else {
        return 'À l\'instant';
      }
    } catch (e) {
      return date.toString();
    }
  }
}

class SoumissionCard extends StatelessWidget {
  final Map<String, dynamic> soumission;
  final VoidCallback? onEvaluate;
  final VoidCallback? onView;

  const SoumissionCard({
    super.key,
    required this.soumission,
    this.onEvaluate,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final amount = soumission['amount']?.toString() ?? '0';
    final status = soumission['status']?.toString().toLowerCase() ?? 'submitted';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    (soumission['customer_name'] ?? 'C')[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        soumission['customer_name'] ?? 'Client inconnu',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        soumission['customer_email'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text(
                  _formatAmount(amount),
                  style: TextStyle(
                    color: Colors.green[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (soumission['delivery_time'] != null) ...[
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    soumission['delivery_time'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
            if (soumission['notes'] != null && soumission['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                soumission['notes'],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (soumission['total_score'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Score: ${soumission['total_score'].toStringAsFixed(1)}/100',
                    style: TextStyle(
                      color: Colors.amber[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (onView != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onView,
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Voir'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                if (onEvaluate != null && status == 'submitted') ...[
                  if (onView != null) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEvaluate,
                      icon: const Icon(Icons.assessment, size: 16),
                      label: const Text('Évaluer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Colors.blue;
      case 'evaluated':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'submitted':
        return 'SOUMIS';
      case 'evaluated':
        return 'ÉVALUÉ';
      case 'accepted':
        return 'ACCEPTÉ';
      case 'rejected':
        return 'REJETÉ';
      default:
        return status.toUpperCase();
    }
  }

  String _formatAmount(String amount) {
    final amountNum = double.tryParse(amount);
    if (amountNum == null) return amount;
    
    if (amountNum >= 1000000) {
      return '${(amountNum / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (amountNum >= 1000) {
      return '${(amountNum / 1000).toStringAsFixed(0)}K FCFA';
    } else {
      return '${amountNum.toStringAsFixed(0)} FCFA';
    }
  }
}

class CriteriaCard extends StatelessWidget {
  final Map<String, dynamic> criteria;
  final bool isEditable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CriteriaCard({
    super.key,
    required this.criteria,
    this.isEditable = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    criteria['name'] ?? 'Critère',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${criteria['weight'] ?? 0}%',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (isEditable) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            if (criteria['description'] != null && criteria['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                criteria['description'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FileUploadWidget extends StatelessWidget {
  final List<File> files;
  final Function(List<File>) onFilesSelected;
  final Function(int) onFileRemoved;
  final bool isLoading;

  const FileUploadWidget({
    super.key,
    required this.files,
    required this.onFilesSelected,
    required this.onFileRemoved,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents (${files.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Zone de drop
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: InkWell(
            onTap: isLoading ? null : _selectFiles,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  size: 32,
                  color: isLoading ? Colors.grey : Colors.blue,
                ),
                const SizedBox(height: 8),
                Text(
                  isLoading ? 'Téléchargement...' : 'Cliquez pour ajouter des fichiers',
                  style: TextStyle(
                    color: isLoading ? Colors.grey : Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'PDF, Word, Excel, Images (max 10MB)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Liste des fichiers
        if (files.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...files.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                leading: Icon(_getFileIcon(file.path)),
                title: Text(
                  file.path.split('/').last,
                  style: const TextStyle(fontSize: 12),
                ),
                subtitle: Text(_formatFileSize(file.lengthSync())),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: isLoading ? null : () => onFileRemoved(index),
                ),
                dense: true,
              ),
            );
          }).toList(),
        ],
      ],
    );
  }

  void _selectFiles() async {
    // Cette fonction devrait utiliser un file picker
    // Pour l'instant, on simule la sélection
    // TODO: Implémenter avec file_picker
  }

  IconData _getFileIcon(String path) {
    final extension = path.split('.').last.toLowerCase();
    
    switch (extension) {
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
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '$bytes B';
    }
  }
}
