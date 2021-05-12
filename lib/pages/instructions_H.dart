import 'package:flutter/material.dart';
import 'package:epibox/decor/default_colors.dart';
import 'package:epibox/decor/text_styles.dart';

class InstructionsHPage extends StatefulWidget {
  @override
  _InstructionsHPageState createState() => _InstructionsHPageState();
}

class _InstructionsHPageState extends State<InstructionsHPage> {
  @override
  Widget build(BuildContext context) {
    final bodyWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).viewInsets.left -
        MediaQuery.of(context).viewInsets.right;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instruções'),
      ),
      body: Center(
        child: ListView(children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'AO INICIAR, VERIFIQUE SE ...',
              style: MyTextStyle(
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight,),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'O Raspberry Pi se encontra ligado à corrente (luz vermelha ligada).',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                          'O(s) dispositivo(s) de aquisição se encontram ligados (luz branca a piscar devagar).',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                          'O(s) dispositivo(s) de aquisição se encontram bem posicionados no paciente.',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text(
                          'O telemóvel se encontra conectado à rede "PreEpiSeizures". Caso contrário, conectar com a password "preepiseizures".',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'PASSO-A-PASSO',
              style: MyTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight,),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              //height: 250.0,
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text('1. Fazer scan do código QR do paciente.',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text: '2. ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          TextSpan(
                              text: 'Conectividade',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  ': Conectar ao servidor e iniciar processo para aquisição.',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text: '3. ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          TextSpan(
                              text: 'Selecionar dispositivos',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  ': Permite selecionar os dispositivos de aquisição default, novos (por escrita ou código QR) ou dispositivos utilizados anteriormente. Para selecionar apenas 1 dispositivo, deixe a outra entrada em branco. Caso queira guardar os novos dispositivos como default, pressione ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          TextSpan(
                              text: '"Definir novo default" ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: 'antes de pressionar ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          TextSpan(
                              text: '"Selecionar".',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight,
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text: '4. ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          TextSpan(
                              text: 'Configurações',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  ': Permite selecionar a pasta onde serão armazenados os dados da aquisição, a frequência de amostragem, os canais a adquirir em cada um dos dispositivos e a que sensores correspondem esses canais. Permite ainda guardar estas configurações como default.',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text: '5. Pressionar o botão ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          TextSpan(
                              text: '"Iniciar" ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                                  'para iniciar a aquisição. Irá ser direcionado para a página de visualização. É normal demorar alguns segundos até ser feito o display dos sinais.',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  '6. Para adicionar uma anotação (ex: Crise, Mudança de bateria, etc...), pressionar o botão à esquerda. ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          TextSpan(
                              text:
                                  'Pode selecionar uma anotação já existente (',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          WidgetSpan(
                              child: Icon(Icons.arrow_drop_down,
                                  color: DefaultColors.textColorOnLight,)),
                          TextSpan(
                              text:
                                  ') ou adicionar uma nova (por escrita). Poderá também retificar o instante de ocorrência ou, caso não seja possível, selecionar a caixa ( ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          WidgetSpan(
                              child: Icon(Icons.check_box_outline_blank,
                                  color: DefaultColors.textColorOnLight,)),
                          TextSpan(
                              text: ').',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  '6. Para terminar a aquisição e guardar os dados, pressionar o botão ',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                          TextSpan(
                              text: '"Parar"',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: '.',
                              style: MyTextStyle(
                                  color: DefaultColors.textColorOnLight)),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'RESOLUÇÃO DE PROBLEMAS',
              style: MyTextStyle(
                fontWeight: FontWeight.bold,
                color: DefaultColors.textColorOnLight,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Não me consigo conectar ao servidor ou ao wifi PreEpiSeizures.',
              style: MyTextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                color: DefaultColors.textColorOnLight,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'O Raspberry Pi pode não ter tido tempo suficiente de iniciar o sistema, espere 1 min e volte a tentar. Caso o problema persista, desligue o Raspberry Pi e tente novamente.',
                        textAlign: TextAlign.justify,
                        style:
                            MyTextStyle(color: DefaultColors.textColorOnLight),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Os passos 2, 3 e 4 não funcionam.',
              style: MyTextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Se um passo não se encontra disponível, significa que existem passos anteriores por finalizar. ',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Em "Selecionar dispositivos", aparece "Endereço MAC" em vez dos números.',
              style: MyTextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Isto significa que o processo não foi iniciado corretamente. Verificar a conexão com o servidor e reininciar o processo.',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Em "Configurações", não aparece a minha PEN USB.',
              style: MyTextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'O Raspberry Pi pode não ter reconhecido a introdução da PEN antes de ser iniciado o processo. Retire e volte a introduzir - e reinicie o processo!',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Em "Configurações", não consigo selecionar os canais/sensores de um (ou ambos) os dispositivos.',
              style: MyTextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Apenas é possível selecionar os canais/sensores do(s) dispositivo(s) que foram selecionados no passo 2. ',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Iniciei a aquisição, mas o servidor disconectou-se.',
              style: MyTextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'O Raspberry Pi pode ter encontrado um problema externo ao EpiBOX (ex: Bluetooth) e não consegue iniciar a aquisição. Desligue o Raspberry Pi e tente novamente.',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Pausei a aquisição e está a demorar muito tempo a retomar.',
              style: MyTextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Ao pausar uma aquisição, retomar a mesma não é imediato - é necessário reconectar aos dispositivos. No entanto, se o tempo de espera parecer demasiado longo, deve parar a aquisição e recomeçar.',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'Saí da aplicação durante uma aquisição. Tenho de reiniciar o processo?',
              style: MyTextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Se a aquisição não tiver sido interrompida e os dispositivos continuam a adquirir (verificar se a luz branca pisca rapidamente), basta conectar-se ao servidor e o passo 4 "Iniciar visualização" deverá ficar disponível.',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'A aplicação diz "A adquirir dados", mas "Disconectado do servidor".',
              style: MyTextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Verifique a ligação wifi - é possível que o telemóvel se tenha disconectado do PreEpiSeizures.',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
            child: Text(
              'A aplicação diz "Conectado ao servidor" e "A adquirir dados", mas não tenho acesso à secção 4. ou os gráficos não estão a ser alterados.',
              style: MyTextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: DefaultColors.textColorOnLight),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
            child: Container(
              width: 0.95 * bodyWidth,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[200], offset: new Offset(5.0, 5.0))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                  child: Column(children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                          'Verifique a ligação wifi - é possível que o telemóvel se tenha disconectado do PreEpiSeizures.',
                          textAlign: TextAlign.justify,
                          style: MyTextStyle(
                              color: DefaultColors.textColorOnLight)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
