#!/bin/bash
#########################################################################################
#                                                                                       #
#  Autor: Matheus Gomes - 21 de Set de 2022.             #
#                                                                                       #
#  Versão: 0.1 - 21 Set 2022 - 15:00.                                                   #
#                                                                                       #
#  Descrição: Script para criar usuários com senha padrão no linux a partir de uma      #
#  lista de usuários.                                                                   #
#                                                                                       #
#########################################################################################

# Com o comando cat, cria a lista de usuários.
# Os campos são: Nome Completo, e-mail e Número de Telefone.
# Cada campo é separado por "," (virgula).
f_userlist(){
cat > lista_usuarios.txt <<FIM
Fulano de Tal,fulano.tal@dom.com.br,(61)9999-9999
Ciclano de Fulano,ciclano.fulano@dom.com.br,(61)9999-9999
Tal de Ciclano,tal.ciclano@dom.com.br,(61)9999-9999
FIM
}

# Com o comando cat, cria a lista de grupos.
f_grouplist(){
cat > lista_grupos.txt <<FIM
adm
sudo
ssh
FIM
}

f_groupcreate(){
    # Executa a função que cria a lista de grupos.
    f_grouplist

    exec 11< lista_grupos.txt
    while read glist <&11; do
        groupadd $glist
    done
    exec 11<&-
}

f_usercreate(){
    # Executa a função que cria os grupos.
    f_groupcreate

    # Executa a função que cria a lista de usuários.
    f_userlist
    
    # Ler a lista de usuário e os usuários por linha.
    exec 12< lista_usuarios.txt
    while read ulist <&12; do
        # Senha padrão que deve ser alterada no primeiro acesso do usuário:
        password="SenhaPadrao@321"

        # Define a váriavel vName com base no 1º e no 3º campo da lista de usuários (Nome Completo, Telefone).
        vName=$(echo $ulist|awk -F "," '{print $1","$3}')

        # Define a váriavel vUserName com base no segundo campo da lista de usuários (e-mail).
        vUserName="$(echo $ulist|awk -F "," '{print $2}'|awk -F "@" '{print $1}')"

        # Grupos.
        vGroups="adm,sudo,ssh"

        # Criptografa a senha:
        vPass=$(openssl passwd -6 "$password")

        # Cria o o usuário.
        useradd -m -p "$vPass" -s /bin/bash -G $vGroups -c "$vName" $vUserName

        # Expira a senha do usuário para força a alteração no primeiro login.
        chage -d 0 $vUserName
    done
    exec 12<&-
}

f_rmlist(){
    rm lista_usuarios.txt
    rm lista_grupos.txt
}
/root/unlock

# Executa a função para criar o usuário.
f_usercreate
