<h2>API de Gerenciamento de Servidores</h2>

Uma API simples para o gerenciamento de servidores e vídeos, desenvolvida em Delphi utilizando o framework Horse.

- Índice
- Descrição
- Funcionalidades
- Instalação
- Como Usar
- Endpoints
- Contribuição
- Licença
- Contato


<h3>Descrição</h3>
Este projeto oferece uma API RESTful para o gerenciamento de servidores e dos vídeos associados a eles. 
Com esta API, os usuários podem criar, remover e listar servidores, além de gerenciar os vídeos armazenados nesses servidores. 
A API foi desenvolvida em Delphi utilizando o framework Horse, e o FireDAC é usado para interações com o banco de dados SQL Server.

<h3>Funcionalidades</h3>
<b>Gerenciamento de Servidores :</b> Criação, remoção e listagem de servidores.<br>
<b>Gerenciamento de Vídeos :</b> Adição, remoção e listagem de vídeos em servidores específicos.<br>
<b>Reciclagem de Vídeos Antigos :</b> Funcionalidade para reciclar (remover) vídeos antigos com base em um critério de dias.<br>
<b>Verificação de Disponibilidade :</b> Checar a disponibilidade de um servidor específico.<br>
<h4>Instalação</h4>
Para rodar o projeto localmente, siga os passos abaixo:

Clone o repositório:

bash
Copiar código
git clone https://github.com/gustavomjo/server.git
cd server
Configure o ambiente Delphi com as dependências necessárias, como o Horse, FireDAC e outras bibliotecas mencionadas no projeto.

Configure a conexão com o banco de dados SQL Server utilizando os parâmetros adequados no arquivo de configuração.

Compile e execute o projeto no Delphi.

<b>Como Usar</b>
Após a instalação e execução, a API estará disponível para interações. Você pode usar ferramentas como Postman ou cURL para enviar requisições para os endpoints disponíveis.

<b>Exemplos:<br>
Criar um servidor:</b><br>
  POST /api/server
  Body: { "id": "001", "name": "Servidor 1", "ip": "192.168.0.1", "port": 8080 }<br>
<b>Listar todos os servidores:</b> <br>
  GET /api/server

<b>Endpoints</b><br>
<b>Servidores</b><br>
GET /api/server: Lista todos os servidores.<br>
POST /api/server: Adiciona um novo servidor.<br>
DELETE /api/server/:serverId: Remove um servidor existente.<br>
GET /api/servers/available/:serverId: Verifica a disponibilidade de um servidor.<br>
<b>Vídeos</b><br>
POST /api/servers/:serverId/videos: Adiciona um vídeo a um servidor.<br>
DELETE /api/servers/:serverId/videos/:videoId: Remove um vídeo de um servidor.<br>
GET /api/servers/:serverId/videos: Lista todos os vídeos em um servidor.<br>
GET /api/servers/:serverId/videos/:videoId/binary: Faz o download do conteúdo binário de um vídeo.<br>
<b>Reciclagem</b><br>
POST /api/recycler/process/:days: Recicla (remove) vídeos antigos com base em um critério de dias.<br>
GET /api/recycler/status: Verifica o status da reciclagem.<br>

<b>Contato</br>
Se você tiver alguma dúvida ou sugestão, sinta-se à vontade para entrar em contato:

<b>Nome:</b> Gustavo<br>
<b>Email:</b> mikizo.jo@gmail.com<br>
<b>GitHub:</b> @gustavomjo
