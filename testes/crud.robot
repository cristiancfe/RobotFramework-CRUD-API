*** Settings ***
Documentation		CRUD 

Library     RequestsLibrary
Library		String
Library		Collections
Library		FakerLibrary	locale=pt_BR


*** Variables ***
${baseUrl}		https://lost.qacoders.dev.br/api
${email_admin}		sysadmin@qacoders.com
${senha_admin}		1234@Test
${token_invalido}		hkhlkhljlj
${email_obrigatorio}	${EMPTY}
${id_user}              ${EMPTY}
${user_mail}    value
${token_admin}    value
${token_user}    value

*** Test Cases ***
Validar login com sucesso
	Realizar Login
Criar usuario
	Criar usuario
Listar usuario
    Listar usuario
logar usuario	
	Realizar Login user
Alterar senha
	Alterar senha
Deletar usuario
    Deletar usuario

*** Keywords ***
Criar sessao
	${headers}		Create Dictionary	content-Type=application/json
	Create Session		alias=develop		url=${baseUrl}		headers=${headers}		verify=true

Realizar Login
    Criar sessao
	${body} 	Create Dictionary
	...		mail=${email_admin}	
	...		password=${senha_admin}
			
	${resposta}		POST On Session		alias=develop	url=/login		json=${body}  expected_status=200	
	
	# Log To Console		RESPONSE 200
	# Log To Console		${resposta}
	# Log To Console		TOKEN GERADO
	# Log To Console		${resposta.json()['token']} 
	# Log To Console  ***********************************
	# Log To Console		JSON DO RESPONSE
	# Log To Console   ${resposta.json()}
	# Log To Console  ***********************************
	# Log To Console		ID DO USER LOGADO
	# Log To Console		${resposta.json()['user']['_id']} 
	# Log To Console  ***********************************
			
	Status Should Be   200  ${resposta}
	Log    ${resposta.json()['token']}
	Set Suite Variable    ${token_admin}    ${resposta.json()['token']}
	
Criar usuario
	${cpf_basico}    FakerLibrary.cpf
	${cpf}		Remove String	    ${cpf_basico}  .	-
	${mail}		FakerLibrary.Email
	${Primeiro_nome}	FakerLibrary.First Name
	${ultimo_nome}		FakerLibrary.Last Name
	${fullName}		Catenate	${Primeiro_nome}	${ultimo_nome}
	
	${body} 	Create Dictionary
	...		fullName=${fullName}
	...		mail=${mail}
	...		password=Cfe@2024
	...		accessProfile=ADMIN
	...		cpf=${cpf}
	...		confirmPassword=Cfe@2024
	
	${headers}      Create Dictionary    Content-Type=Application/json    Authorization=${token_admin}
    
	${resposta}  POST On Session  alias=develop    url=/user/    json=${body}    headers=${headers} 	expected_status=201

	# Log To Console		${resposta.json()} 
	# Log To Console		${resposta.json()['user']['_id']}
	# Log To Console		${resposta.json()['user']['fullName']}
	# Log To Console		${resposta.json()['user']['mail']}
	

	Set Suite Variable	${novo_user}	${resposta.json()['user']['fullName']} 
	Set Suite Variable	${user_mail}	${resposta.json()['user']['mail']}
	Set Suite Variable	${user_new_id}		${resposta.json()['user']['_id']}
	Set Suite Variable  ${id_user}			${resposta.json()['user']['_id']}
		
	Log To Console    novo usuario
	Log To Console    ${novo_user}
	Log 		      ${novo_user}
	Log To Console    novo email
	Log To Console    ${user_mail}
	Log 		      ${user_mail}

Listar usuario
	
	${resposta}			GET On Session		alias=develop	url=/user/${id_user}?token=${token_admin}		expected_status=200

	Log 	${resposta.json()}


Realizar Login user
	${body} 	Create Dictionary
	...		mail=${user_mail}
	...		password=Cfe@2024
	
	Criar sessao	
	${resposta}		POST On Session		alias=develop	url=/login		json=${body}  expected_status=200	
	
	# Log To Console		RESPONSE 200
	# Log To Console		${resposta}
	# Log To Console		TOKEN GERADO
	# Log To Console		${resposta.json()['token']} 
	# Log 				${resposta.json()['token']} 
	# Log To Console  ***********************************
	# Log To Console		JSON DO RESPONSE
	# Log To Console   ${resposta.json()}
	# Log To Console  ***********************************
	# Log To Console		ID DO USER LOGADO
	# Log To Console		${resposta.json()['user']['_id']} 
	# Log To Console  ***********************************	
	# Log To Console		${resposta.json()['user']['fullName']}
	# Log To Console		${resposta.json()['user']['mail']}

	Set Suite Variable	${login_novo_user}	${resposta.json()['user']['fullName']} 
	Set Suite Variable	${login_user_mail}	${resposta.json()['user']['mail']}
	Set Suite Variable	${token_user}		${resposta.json()['token']}
	
	
	# Log To Console  	${login_novo_user}
	# Log To Console  	${login_user_mail}
	# Log To Console		${resposta.json()['token']} 
	# Log To Console		${resposta.json()['user']['_id']} 
	Log 			  	${login_novo_user}
	Log 			  	${login_user_mail}
	Log					${token_user}
	Log 				${id_user} 

Alterar senha
    ${headers}    Create Dictionary    Content-Type=Application/json
    ...    Authorization=${token_user}
 
	${body} 	Create Dictionary
	...		password=Cfe@2015
	...		confirmPassword=Cfe@2015
		
	${resposta}  PUT On Session  alias=develop  url=/user/password/${id_user}  json=${body}    headers=${headers} 	expected_status=200

	Log 		${resposta.json()} 
	
	BuiltIn.Should Be Equal As Strings  ${resposta.json()['msg']}		Senha atualizada com sucesso!

  
Deletar usuario
    ${headers}      Create Dictionary    Content-Type=Application/json    Authorization=${token_admin}

	${resposta}			DELETE On Session		alias=develop	url=/user/${id_user}?token=${token_admin}		expected_status=200

	Log  ${resposta.json()['msg']}	

	BuiltIn.Should Be Equal As Strings  ${resposta.json()['msg']}		Usuário deletado com sucesso!.
	
