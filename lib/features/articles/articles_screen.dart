import 'package:flutter/material.dart';
import 'package:appgestion/models/article.dart';
import 'package:appgestion/services/services.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  _ArticlesScreenState createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final ArticleService _articleService = ArticleService();
  List<Article> _articles = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await _articleService.getArticles();
      
      if (response.success && response.data != null) {
        setState(() {
          _articles = response.data!;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Erreur lors du chargement des articles';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion au serveur';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadArticles,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddArticleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadArticles,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty) {
      return const Center(child: Text('Aucun article disponible'));
    }

    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return ListTile(
          title: Text(article.name),
          subtitle: Text('${article.price} € - Stock: ${article.quantity}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditArticleDialog(article),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteArticle(article.id),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddArticleDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantité'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final article = Article(
                id: '',
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0,
                quantity: int.tryParse(quantityController.text) ?? 0,
                category: '',
                unit: 'unité',
              );
              
              final response = await _articleService.createArticle(article);
              
              if (mounted) {
                Navigator.pop(context);
                if (response.success) {
                  _loadArticles();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Article ajouté avec succès')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response.message ?? 'Erreur lors de l\'ajout')),
                  );
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showEditArticleDialog(Article article) {
    final nameController = TextEditingController(text: article.name);
    final priceController = TextEditingController(text: article.price.toString());
    final quantityController = TextEditingController(text: article.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'article'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantité'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedArticle = article.copyWith(
                name: nameController.text,
                price: double.tryParse(priceController.text) ?? 0,
                quantity: int.tryParse(quantityController.text) ?? 0,
              );
              
              final response = await _articleService.updateArticle(article.id, updatedArticle);
              
              if (mounted) {
                Navigator.pop(context);
                if (response.success) {
                  _loadArticles();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Article mis à jour avec succès')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response.message ?? 'Erreur lors de la mise à jour')),
                  );
                }
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteArticle(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet article ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _articleService.deleteArticle(id);
      
      if (mounted) {
        if (response.success) {
          _loadArticles();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article supprimé avec succès')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? 'Erreur lors de la suppression')),
          );
        }
      }
    }
  }
}
