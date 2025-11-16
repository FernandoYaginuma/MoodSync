import 'package:flutter/material.dart';
import 'package:android2/theme/colors.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Termos de Uso",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.blueLogo.withOpacity(0.6),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),

          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.description, color: Colors.blue, size: 28),
                    SizedBox(width: 10),
                    Text(
                      "Termos de Uso",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  _textoTermos,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.55,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const String _textoTermos = '''
TERMOS DE USO — MoodSync

Última atualização: Novembro de 2025


Bem-vindo ao MoodSync (“Aplicativo”). Ao utilizar nossos serviços, você concorda com estes Termos de Uso, que definem as regras de utilização do aplicativo, suas funcionalidades, responsabilidades e limites legais.

Por favor, leia atentamente antes de criar uma conta.



===========================
1. OBJETIVO DO APLICATIVO
===========================

O MoodSync é uma ferramenta voltada ao registro diário de emoções, acompanhamento do humor e conexão entre pacientes e profissionais de saúde (psicólogos/psiquiatras).

O aplicativo não substitui atendimento médico ou psicológico; ele serve como plataforma de apoio e organização de informações emocionais.



===========================
2. ACEITAÇÃO DOS TERMOS
===========================

Ao se cadastrar ou utilizar qualquer funcionalidade do MoodSync, você declara que:

• leu e concorda com estes Termos de Uso;  
• tem 13 anos ou mais (ou está autorizado por um responsável legal);  
• fornece informações verdadeiras e atualizadas;  
• consente com o tratamento dos seus dados pessoais conforme nossa Política de Privacidade.

Se você não concordar, não deve utilizar o aplicativo.



==================================
3. CADASTRO E CONTA DO USUÁRIO
==================================

Para utilizar o MoodSync, o usuário deverá fornecer dados como:

• nome completo  
• e-mail  
• telefone  
• data de nascimento  
• sexo  
• senha  

É responsabilidade do usuário:

• manter a confidencialidade da sua senha;  
• não compartilhar sua conta com terceiros;  
• avisar imediatamente caso suspeite de acesso indevido.  

O MoodSync não se responsabiliza por danos decorrentes de uso incorreto da conta pelo usuário.



==================================
4. DADOS DE SAÚDE E HUMOR
==================================

O usuário poderá registrar informações emocionais, incluindo:

• sentimentos diários  
• anotações pessoais  
• datas e registros de humor  

Esses dados são considerados sensíveis pela LGPD e serão armazenados de forma segura no Firebase.

O paciente poderá, opcionalmente, liberar acesso aos dados para um profissional vinculado.



==========================================
5. RESPONSABILIDADE DOS PROFISSIONAIS
==========================================

Profissionais cadastrados devem:

• respeitar a privacidade do paciente;  
• utilizar as informações somente para fins de acompanhamento;  
• nunca repassar dados a terceiros.  

O MoodSync não se responsabiliza por condutas individuais de profissionais.



===========================
6. USO PERMITIDO
===========================

O usuário concorda em NÃO utilizar o aplicativo para:

• praticar assédio, abuso, discriminação ou conduta ilegal;  
• tentar acessar contas de terceiros;  
• manipular, copiar ou redistribuir o aplicativo sem autorização;  
• enviar informações falsas ou enganosas.



===========================
7. LIMITAÇÕES DO SERVIÇO
===========================

O MoodSync NÃO oferece emergências psicológicas.

Em casos de risco imediato, procure ajuda profissional, hospitais ou serviços locais de apoio emocional.

O aplicativo também não garante:

• disponibilidade contínua;  
• ausência total de erros;  
• funcionamento correto em aparelhos modificados.



=======================================
8. EXCLUSÃO DA CONTA E DOS DADOS
=======================================

O usuário pode solicitar:

• exclusão da conta;  
• remoção total dos dados pessoais;  
• cancelamento do vínculo com profissionais.  

A exclusão será realizada conforme a Política de Privacidade e os prazos técnicos do Firebase.



===========================
9. ALTERAÇÕES NOS TERMOS
===========================

O MoodSync pode atualizar estes Termos a qualquer momento.

A versão mais recente estará sempre disponível no aplicativo.

Ao continuar utilizando o aplicativo, você concorda automaticamente com as alterações realizadas.



===========================
10. DISPOSIÇÕES FINAIS
===========================

Caso qualquer cláusula destes Termos seja considerada inválida, isso não afetará as demais disposições.

Ao clicar em “Cadastrar Paciente” ou “Cadastrar Profissional”, você declara que leu, compreendeu e concorda com estes Termos de Uso.



===========================
11. CONTATO E SUPORTE
===========================

Para dúvidas, sugestões, solicitações ou qualquer assunto relacionado ao uso do aplicativo, entre em contato com a equipe de desenvolvimento:

📩 moodsync.contactme@gmail.com

Responderemos o mais breve possível.
''';
