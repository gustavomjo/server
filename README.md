## API de Gerenciamento de Servidores

Uma API simples para o gerenciamento de servidores e vídeos, desenvolvida em Delphi utilizando o framework Horse.

### Índice

- [Descrição](#descrição)
- [Funcionalidades](#funcionalidades)
- [Instalação](#instalação)
- [Como Usar](#como-usar)
- [Endpoints](#endpoints)
- [Contribuição](#contribuição)
- [Licença](#licença)
- [Contato](#contato)

### Descrição

Este projeto oferece uma API RESTful para o gerenciamento de servidores e dos vídeos associados a eles. Com esta API, os usuários podem criar, remover e listar servidores, além de gerenciar os vídeos armazenados nesses servidores. A API foi desenvolvida em Delphi utilizando o framework Horse, e o FireDAC é usado para interações com o banco de dados SQL Server.

### Funcionalidades

- **Gerenciamento de Servidores**: Criação, remoção e listagem de servidores.
- **Gerenciamento de Vídeos**: Adição, remoção e listagem de vídeos em servidores específicos.
- **Reciclagem de Vídeos Antigos**: Funcionalidade para reciclar (remover) vídeos antigos com base em um critério de dias.
- **Verificação de Disponibilidade**: Checar a disponibilidade de um servidor específico.

### Instalação

Para rodar o projeto localmente, siga os passos abaixo:

1. Clone o repositório:

    ```bash
    git clone https://github.com/gustavomjo/server.git
    cd server
    ```

2. Configure o ambiente Delphi com as dependências necessárias, como o Horse, FireDAC e outras bibliotecas mencionadas no projeto.

3. Configure a conexão com o banco de dados SQL Server utilizando os parâmetros adequados no arquivo de configuração.

4. Compile e execute o projeto no Delphi.

### Como Usar

Após a instalação e execução, a API estará disponível para interações. Você pode usar ferramentas como Postman ou cURL para enviar requisições para os endpoints disponíveis.

#### Exemplos:

- **Criar um servidor**:

    ```http
    POST /api/server
    Body: { "id": "001", "name": "Servidor 1", "ip": "192.168.0.1", "port": 8080 }
    ```

- **Listar todos os servidores**:

    ```http
    GET /api/server
    ```

### Endpoints

#### Servidores

- **GET** `/api/server`: Lista todos os servidores.
- **POST** `/api/server`: Adiciona um novo servidor.
- **DELETE** `/api/server/:serverId`: Remove um servidor existente.
- **GET** `/api/servers/available/:serverId`: Verifica a disponibilidade de um servidor.

#### Vídeos

- **POST** `/api/servers/:serverId/videos`: Adiciona um vídeo a um servidor.
- **DELETE** `/api/servers/:serverId/videos/:videoId`: Remove um vídeo de um servidor.
- **GET** `/api/servers/:serverId/videos`: Lista todos os vídeos em um servidor.
- **GET** `/api/servers/:serverId/videos/:videoId/binary`: Faz o download do conteúdo binário de um vídeo.

#### Reciclagem

- **POST** `/api/recycler/process/:days`: Recicla (remove) vídeos antigos com base em um critério de dias.
- **GET** `/api/recycler/status`: Verifica o status da reciclagem.

### Contribuição

Contribuições são bem-vindas! Se você deseja contribuir, siga os passos abaixo:

1. Faça um fork do projeto.
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`).
3. Commit suas alterações (`git commit -m 'Adiciona NovaFuncionalidade'`).
4. Faça o push para a branch (`git push origin feature/NovaFuncionalidade`).
5. Abra um Pull Request.

### Licença

Este projeto está licenciado sob a licença MIT. Para mais detalhes, consulte o arquivo [LICENSE](LICENSE).

### Contato

Se você tiver alguma dúvida ou sugestão, sinta-se à vontade para entrar em contato:

- **Nome**: Gustavo
- **Email**: [mikizo.jo@gmail.com](mailto:mikizo.jo@gmail.com)
- **GitHub**: [@gustavomjo](https://github.com/gustavomjo)
