import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/receita.dart';
import '../services/receita_service.dart';
import '../theme/app_theme.dart';
import '../widgets/receita_card.dart';
import 'detalhes_receita_screen.dart';
import 'nova_receita_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReceitaService service = ReceitaService();
  final TextEditingController busca = TextEditingController();

  List<Receita> receitas = [];
  Set<String> favoritas = {};

  bool carregando = true;
  String erro = '';
  String filtro = 'TODAS';

  @override
  void initState() {
    super.initState();
    carregarReceitas();
    carregarFavoritas();
  }

  Future<void> carregarReceitas() async {
    setState(() {
      carregando = true;
      erro = '';
    });

    try {
      final dados = await service.listar();

      if (!mounted) return;

      setState(() {
        receitas = dados;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erro = e.toString();
        carregando = false;
      });
    }
  }

  Future<void> carregarFavoritas() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      favoritas = (prefs.getStringList('receitas_favoritas') ?? []).toSet();
    });
  }

  Future<void> alternarFavorita(Receita receita) async {
    final id = (receita.id ?? receita.nome).toString();

    setState(() {
      if (favoritas.contains(id)) {
        favoritas.remove(id);
      } else {
        favoritas.add(id);
      }
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('receitas_favoritas', favoritas.toList());
  }

  Future<void> abrirCadastro() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NovaReceitaScreen()),
    );

    if (resultado == true) {
      carregarReceitas();
    }
  }

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termo = busca.text.toLowerCase();

    final lista = receitas.where((receita) {
      final correspondeTexto =
          receita.nome.toLowerCase().contains(termo) ||
          receita.ingredientes.toLowerCase().contains(termo);

      final correspondeTipo =
          filtro == 'TODAS' || receita.tipo.toUpperCase() == filtro;

      final correspondeFavorita =
          filtro != 'FAVORITAS' ||
          favoritas.contains((receita.id ?? receita.nome).toString());

      return correspondeTexto && correspondeTipo && correspondeFavorita;
    }).toList();

    return Scaffold(
      drawer: _menuLateral(),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SUA COZINHA, SEU ESTILO',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: AppTheme.laranja,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Livro de Receitas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.texto,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.laranja,
        foregroundColor: Colors.white,
        onPressed: abrirCadastro,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nova receita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.laranja,
        backgroundColor: AppTheme.superficie,
        onRefresh: carregarReceitas,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [AppTheme.laranja, AppTheme.laranjaEscuro],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'O que vamos cozinhar hoje?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Descubra sabores e encontre sua próxima receita favorita.',
                          style: TextStyle(color: Colors.white, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.local_dining, size: 56, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: busca,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppTheme.texto),
              decoration: const InputDecoration(
                hintText: 'Buscar receita ou ingrediente...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textoSuave),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Explore as receitas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.texto,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _categoria('TODAS', 'Todas'),
                  _categoria('DOCE', 'Doces'),
                  _categoria('SALGADA', 'Salgadas'),
                  _categoria('BEBIDA', 'Bebidas'),
                  _categoria('FAVORITAS', 'Favoritas'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (carregando)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.laranja),
                ),
              )
            else if (erro.isNotEmpty)
              _mensagemErro()
            else if (lista.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Nenhuma receita encontrada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textoSuave),
                ),
              )
            else
              ...lista.map(
                (receita) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReceitaCard(
                    receita: receita,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalhesReceitaScreen(
                            receita: receita,
                            favorita: favoritas.contains(
                              (receita.id ?? receita.nome).toString(),
                            ),
                            onFavoritar: () => alternarFavorita(receita),
                            onExcluir: () => service.excluir(receita.id),
                          ),
                        ),
                      );

                      if (mounted) carregarReceitas();
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _categoria(String valor, String titulo) {
    final selecionada = filtro == valor;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(titulo),
        selected: selecionada,
        showCheckmark: false,
        onSelected: (_) => setState(() => filtro = valor),
        selectedColor: AppTheme.laranja,
        backgroundColor: AppTheme.superficie,
        labelStyle: TextStyle(
          color: selecionada ? Colors.white : AppTheme.textoSuave,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide(
          color: selecionada ? AppTheme.laranja : AppTheme.borda,
        ),
      ),
    );
  }

  Widget _mensagemErro() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.superficie,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borda),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 40, color: AppTheme.laranja),
          const SizedBox(height: 10),
          const Text(
            'Não conseguimos carregar as receitas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.texto,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            erro,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.textoSuave),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: carregarReceitas,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _menuLateral() {
    return Drawer(
      backgroundColor: AppTheme.fundo,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.laranja, AppTheme.laranjaEscuro],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.restaurant_menu, size: 40, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Livro de Receitas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Feito para quem ama cozinhar',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: AppTheme.laranja),
              title: const Text(
                'Início',
                style: TextStyle(color: AppTheme.texto),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: AppTheme.laranja),
              title: const Text(
                'Nova receita',
                style: TextStyle(color: AppTheme.texto),
              ),
              onTap: () {
                Navigator.pop(context);
                abrirCadastro();
              },
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Livro de Receitas • Flutter',
                style: TextStyle(color: AppTheme.textoSuave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}