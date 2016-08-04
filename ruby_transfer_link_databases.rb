# ==========================================================================================================================
#  -----------------------------
#  Autor: Manuel Ábalos Serrano
#        Versión: 0.0.1 
#  -----------------------------
# Script que transfiere los registros de un modelo de una base de datos a otra distinta entre dos tablas cuya relación es 1:N
# Este script debe de ser modificado y ajustado dependiendo de los modelos con los que se trabaje.
# ==========================================================================================================================

require 'mysql2'

@db_host  = "localhost"
@db_user  = "root"
@db_pass  = "root"
@db_name_1 = "ISE_temporal"
@db_name_2 = "redmine_csme_test_2"

client_1 = Mysql2::Client.new(:host => @db_host, :username => @db_user, :password => @db_pass, :database => @db_name_1)
@results = client_1.query("SELECT * FROM ise_adjudicaciones_expedientes;")

# ===========================================
#  {"ID_EXPEDIENTE"=>"492", "CODIGO_EXPEDIENTE"=>"3/2000/001", "CODIGO_PROVEEDOR"=>"53", "PROVEEDOR"=>"EL CORTE INGLES S.A.", "CODIGO_TIPO_MATERIAL"=>"0", "TIPO_MATERIAL"=>"MOBILIARIO", "CODIGO_ARTICULO"=>"0668", "ARTICULO"=>"CALENTADOR-RADIADOR"}
# ===========================================

client_2 = Mysql2::Client.new(:host => @db_host, :username => @db_user, :password => @db_pass, :database => @db_name_2)

@results.each_with_index do |result, index|

	# INSERT INTO 'GG_FILES'
	print "=======================================================\n"
	print "REGISTRO Nº #{index + 1} -> #{result}\n"
	print "-------------------------------------------------------\n\n"

	@file_count = client_2.query("SELECT * FROM gg_files WHERE identity_file = #{result['ID_EXPEDIENTE'].to_i};").count 
	if @file_count == 0
		client_2.query("INSERT INTO `gg_files` (`identity_file`, `code_file`) VALUES (#{result['ID_EXPEDIENTE'].to_i}, '#{result['CODIGO_EXPEDIENTE']}');")
		gg_file_id = client_2.last_id
	else
		@file = client_2.query("SELECT * FROM gg_files WHERE identity_file = #{result['ID_EXPEDIENTE'].to_i};")
		gg_file_id = @file.first['id']
	end

	# INSERT INTO 'GG_ARTICLES'
	client_2.query("INSERT INTO `gg_articles` (`gg_file_id`, `code_article`, `name_article`, `code_provider`, `name_provider`, `code_type_material`, `type_material`) VALUES (#{gg_file_id}, '#{result['CODIGO_ARTICULO']}', '#{result['ARTICULO']}', '#{result['CODIGO_PROVEEDOR']}', '#{result['PROVEEDOR']}', #{result['CODIGO_TIPO_MATERIAL'].to_i}, '#{result['TIPO_MATERIAL'].to_s}');")

end
