import 'package:flutter/material.dart';
import 'package:android2/theme/colors.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Política de Privacidade",
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
                    Icon(Icons.privacy_tip, color: Colors.blue, size: 28),
                    SizedBox(width: 10),
                    Text(
                      "Política de Privacidade",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 16),

                const Text(
                  _politicaTexto,
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

const String _politicaTexto = '''
POLÍTICA DE PRIVACIDADE — MoodSync
(Atualizado em Março de 2025)


A Política de Privacidade do MoodSync explica como tratamos seus dados pessoais e dados sensíveis, conforme determina a Lei Geral de Proteção de Dados (LGPD – Lei nº 13.709/2018).

Esta política descreve quais dados coletamos, como armazenamos, como utilizamos e quais são seus direitos como usuário.



===========================
1. DADOS COLETADOS
===========================

O MoodSync coleta apenas informações necessárias para seu funcionamento adequado e seguro. Isso inclui:

• Nome  
• E-mail  
• Telefone  
• Data de nascimento  
• Sexo  

Além de dados sensíveis relacionados ao uso do app, como:

• Registros de humor  
• Emoções selecionadas  
• Anotações pessoais do diário  
• Compartilhamento autorizado com profissionais  

Coletamos também informações técnicas, como:

• Modelo do dispositivo  
• Sistema operacional  
• Endereço IP  
• Logs de erros  



===========================
2. USO DOS DADOS
===========================

Os dados coletados são utilizados para:

• Criar e gerenciar sua conta  
• Autenticação e segurança  
• Registro e visualização de emoções diárias  
• Sincronização de dados entre paciente e profissional (quando autorizado)  
• Melhoria contínua do aplicativo e análise de desempenho  



================================
3. ARMAZENAMENTO (FIREBASE)
================================

Todos os dados são armazenados com segurança utilizando os serviços Firebase:

• Firebase Authentication  
• Cloud Firestore  
• Firebase Storage (se utilizado em funcionalidades futuras)  

O Firebase utiliza criptografia, servidores seguros e certificações internacionais para proteção de dados.



===========================
4. COMPARTILHAMENTO
===========================

Seus dados **não são compartilhados com nenhum terceiro** fora do contexto do aplicativo.

O compartilhamento ocorre **apenas** quando você autoriza vínculo com um profissional de saúde dentro do app.

Jamais compartilhamos dados com:

• anunciantes  
• parceiros comerciais  
• empresas externas  
• redes sociais  



===========================
5. SEGURANÇA
===========================

Para proteger seus dados, adotamos:

• Criptografia de tráfego (HTTPS)  
• Proteção de senha via Firebase Authentication  
• Regras de segurança no Firestore  
• Tokens de autenticação  
• Camadas internas de validação  



===========================
6. SEUS DIREITOS (LGPD)
===========================

Você pode solicitar a qualquer momento:

• Acesso aos seus dados  
• Correção de informações  
• Exclusão da conta  
• Portabilidade  
• Cancelamento de compartilhamento com profissional  
• Remoção total dos dados do banco  

Para exercer seus direitos, envie um e-mail para:

📩 moodsync.contactme@gmail.com



===========================
7. EXCLUSÃO DOS DADOS
===========================

Você pode solicitar a exclusão total dos seus dados.  
O processo é realizado seguindo os prazos e limitações técnicas do Firebase, que pode levar alguns dias para remover todos os registros.



===========================
8. MUDANÇAS NESTA POLÍTICA
===========================

Esta Política de Privacidade pode ser atualizada periodicamente.

A versão mais recente estará sempre disponível no aplicativo.  
Continuar utilizando o app após alterações significa que você está de acordo com a nova versão.



===========================
9. ACEITE DA POLÍTICA
===========================

Ao utilizar o MoodSync, você declara que leu, compreendeu e concorda com esta Política de Privacidade.

''';
