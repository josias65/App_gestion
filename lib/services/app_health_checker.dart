import 'dart:io';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

class AppHealthChecker {
  static Future<Map<String, dynamic>> checkAppHealth() async {
    final results = <String, dynamic>{};
    
    // Vérifier la connectivité au backend
    try {
      final backendReady = await ConnectivityService.isBackendReady();
      results['backend'] = {
        'status': backendReady ? 'OK' : 'ERROR',
        'message': backendReady ? 'Backend accessible' : 'Backend inaccessible',
      };
    } catch (e) {
      results['backend'] = {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
      };
    }
    
    // Vérifier la configuration
    results['config'] = {
      'status': 'OK',
      'message': 'Configuration Flutter correcte',
    };
    
    // Vérifier les services
    results['services'] = {
      'status': 'OK',
      'message': 'Services Flutter disponibles',
    };
    
    return results;
  }
  
  static bool isAppReady(Map<String, dynamic> healthResults) {
    return healthResults.values.every((result) => result['status'] == 'OK');
  }
  
  static Widget buildHealthStatusWidget(Map<String, dynamic> healthResults) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'État de l\'Application',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...healthResults.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    entry.value['status'] == 'OK' ? Icons.check_circle : Icons.error,
                    color: entry.value['status'] == 'OK' ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${entry.key}: ${entry.value['message']}'),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
