import 'package:shared_preferences/shared_preferences.dart';
import '../../models/anuncio.dart';
import 'database_helper.dart';

class AnuncioHelper {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Helper interno para obter o ID do usuário logado
  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 1;
  }

  Future<int> salvarAnuncio(Anuncio anuncio) async {
    final db = await _dbHelper.db;
    final userId = await _getUserId();

    final mapa = anuncio.toMap();
    mapa['userId'] = userId; // Associa o anúncio ao ID do usuário atual

    return await db.insert('anuncios', mapa);
  }

  Future<List<Anuncio>> listarAnuncios() async {
    final db = await _dbHelper.db;
    final userId = await _getUserId();

    var resultado = await db.query(
      'anuncios',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    if (resultado.isEmpty) {
      final padroes = [
        Anuncio(
          titulo: 'Smart TV 50" Crystal UHD 4K Samsung',
          descricao:
              'Processador Crystal 4K, Tela sem limites, Alexa built-in.',
          preco: 2299.00,
          imagem: 'assets/tv.png',
          contato: '(11) 99999-8888',
        ),
        Anuncio(
          titulo: 'Smartphone Samsung Galaxy A54 128GB',
          descricao: '5G 8GB RAM Câmera Tripla Traseira de 50MP.',
          preco: 1499.00,
          imagem: 'assets/celular.jpg',
          contato: '(11) 98888-7777',
        ),
      ];

      for (final item in padroes) {
        final mapa = item.toMap();
        mapa['userId'] = userId;
        await db.insert('anuncios', mapa);
      }

      resultado = await db.query(
        'anuncios',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'id DESC',
      );
    }

    return resultado.map((map) => Anuncio.fromMap(map)).toList();
  }

  Future<int> atualizarAnuncio(Anuncio anuncio) async {
    final db = await _dbHelper.db;
    return await db.update(
      'anuncios',
      anuncio.toMap(),
      where: 'id = ?',
      whereArgs: [anuncio.id],
    );
  }

  Future<int> deletarAnuncio(int id) async {
    final db = await _dbHelper.db;
    return await db.delete(
      'anuncios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
