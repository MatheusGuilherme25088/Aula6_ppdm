import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../theme/app_theme.dart';

class ReceitaCard extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;

  const ReceitaCard({super.key, required this.receita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imagemUrl = receita.img.trim();

    return Card(
      color: AppTheme.superficie,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppTheme.borda),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imagemUrl.isNotEmpty
                    ? Image.network(
                        imagemUrl,
                        width: 100,
                        height: 110,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                        errorBuilder: (_, __, ___) => _imagemPadrao(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }

                          return Container(
                            width: 100,
                            height: 110,
                            color: AppTheme.superficieAlta,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              color: AppTheme.laranja,
                              strokeWidth: 2,
                            ),
                          );
                        },
                      )
                    : _imagemPadrao(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.laranjaTransparente,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        receita.tipo.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.laranja,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      receita.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.texto,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      receita.ingredientes.isEmpty
                          ? 'Confira os ingredientes'
                          : receita.ingredientes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text(
                          'Ver receita',
                          style: TextStyle(
                            color: AppTheme.laranja,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppTheme.laranja,
                        ),
                      ],
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

  Widget _imagemPadrao() {
    return Container(
      width: 100,
      height: 110,
      color: AppTheme.superficieAlta,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant,
        size: 36,
        color: AppTheme.textoSuave,
      ),
    );
  }
}