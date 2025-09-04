import 'package:flutter/material.dart';
import '../database/sync_service.dart';
import '../database/database_manager.dart';

class SyncStatusWidget extends StatefulWidget {
  final bool showDetails;
  
  const SyncStatusWidget({
    super.key,
    this.showDetails = false,
  });

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = SyncService.isOnline;
    final isSyncing = SyncService.isSyncing;
    final lastSync = DatabaseManager.getLastSyncTime();
    final syncErrors = DatabaseManager.getSyncErrors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(isOnline, isSyncing, syncErrors.isNotEmpty),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(isOnline, isSyncing, syncErrors.isNotEmpty),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(isOnline, isSyncing, syncErrors.isNotEmpty),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.showDetails && lastSync != null) ...[
            const SizedBox(width: 8),
            Text(
              'Dernière sync: ${_formatLastSync(lastSync)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
          if (syncErrors.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showSyncErrors(context, syncErrors),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${syncErrors.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(bool isOnline, bool isSyncing, bool hasErrors) {
    if (hasErrors) return Colors.red;
    if (isSyncing) return Colors.orange;
    if (isOnline) return Colors.green;
    return Colors.grey;
  }

  IconData _getStatusIcon(bool isOnline, bool isSyncing, bool hasErrors) {
    if (hasErrors) return Icons.error;
    if (isSyncing) return Icons.sync;
    if (isOnline) return Icons.cloud_done;
    return Icons.cloud_off;
  }

  String _getStatusText(bool isOnline, bool isSyncing, bool hasErrors) {
    if (hasErrors) return 'Erreurs de sync';
    if (isSyncing) return 'Synchronisation...';
    if (isOnline) return 'En ligne';
    return 'Hors ligne';
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }

  void _showSyncErrors(BuildContext context, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreurs de synchronisation'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  errors[index],
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              DatabaseManager.clearSyncErrors();
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Effacer'),
          ),
          TextButton(
            onPressed: () {
              SyncService.forceSync();
              Navigator.of(context).pop();
            },
            child: const Text('Réessayer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class SyncButton extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  final VoidCallback? onPressed;

  const SyncButton({
    super.key,
    required this.isOnline,
    required this.isSyncing,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isOnline && !isSyncing ? onPressed : null,
      icon: isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(
              isOnline ? Icons.sync : Icons.cloud_off,
              color: isOnline ? Colors.white : Colors.grey,
            ),
      tooltip: isOnline
          ? (isSyncing ? 'Synchronisation en cours...' : 'Synchroniser maintenant')
          : 'Pas de connexion internet',
    );
  }
}
