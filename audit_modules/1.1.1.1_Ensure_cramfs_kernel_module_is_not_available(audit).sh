#!/usr/bin/env bash
{
    l_output="" l_output2="" l_output3="" l_dl="" salida=""# Unset output variables
        #l_output: Mensajes de configuración correcta
        #l_output2: Errores de auditoría
        #l_output3: Información adicional
        #l_dl: Bandera para verificación de denegación
    l_mname="cramfs" # Define el módulo a verificar (cramfs).
    l_mtype="fs" # Tipo de módulo (fs = filesystem).
    l_searchloc="/lib/modprobe.d/*.conf /usr/local/lib/modprobe.d/*.conf /run/modprobe.d/*.conf /etc/modprobe.d/*.conf" #Rutas donde buscar configuraciones de módulos.
    l_mpath="/lib/modules/**/kernel/$l_mtype" #Ruta base de módulos del kernel (usando wildcard ** para todas las versiones).
    l_mpname="$(tr '-' '_' <<< "$l_mname")" #Normaliza el nombre del módulo (reemplaza - por _).
    l_mndir="$(tr '-' '/' <<< "$l_mname")" #Convierte el nombre en ruta (ej: cramfs → cramfs/).
    module_loadable_chk() 
    {
        # Verifica si el módulo puede ser cargado. 
        l_loadable="$(modprobe -n -v "$l_mname")" 
        #comando 'modprobe -n -v cramfs' 
        #Simula la carga del módulo (-n = dry-run) y muestra el comando que se ejecutaría
        ["$(wc -l <<< "$l_loadable")" -gt "1" ] && l_loadable="$(grep -P -- "(\\h*install\\b$l_mname\\b" <<< "$l_loadable")"
        # wc -l -> conteos desde la entrada estándar, ya sea de palabras, caracteres o saltos de líneas
        # grep -P -> ayuda a realizar búsquedas utilizando expresiones regulares compatibles con Perl
        # Si hay múltiples líneas, filtra solo la línea relevante con el comando install.
        if grep -Pq -- '^\h*install \/bin\/(true|false)' <<< "$l_loadable"; then
            #Propósito: Busca patrones que indiquen que el módulo está bloqueado (/bin/true o /bin/false).
            l_output="$l_output\n - module: \"$l_mname\" is not loadable: \"$l_loadable\""
            #Si está bloqueado, agrega mensaje positivo a l_output.
        else
            l_output2="$l_output2\n - module: \"$l_mname\" is loadable: \"$l_loadable\""
            #Explicación: Si NO está bloqueado, agrega error a l_output2.
        fi
    }
    module_loaded_chk()
    {
        # Verifica si el módulo está cargado actualmente.
        if ! lsmod | grep "$l_mname" > /dev/null 2>&1; then
            #El objetivo de lsmod es proporcionar una lista de los módulos del kernel que están actualmente cargados en el sistema
            #Lista módulos cargados y busca cramfs.
            l_output="$l_output\n - module: \"$l_mname\" is not loaded"
            # Si NO está cargado, agrega mensaje positivo.
        else
            l_output2="$l_output2\n - module: \"$l_mname\" is loaded"
            # Si ESTÁ cargado, agrega error.
        fi
    }
    module_deny_chk()
    {
        # Verifica si el módulo está denegado (blacklisted).
        l_dl="y"
        # Bandera para indicar que se verificó la denegación.
        if modprobe --showconfig | grep -Pq -- '^\h*blacklist\h+'"$l_mpname"'\b'; then
            #  El comando modprobe --showconfig imprime la configuración actual y luego finaliza
            #  Busca directivas blacklist en la configuración.
            l_output="$l_output\n - module: \"$l_mname\" is deny listed in: \"$(grep -Pls --"^\h*blacklist\h+$l_mname\b" $l_searchloc)\""
            #Si está denegado, agrega ubicación del archivo de configuración.
        else
            l_output2="$l_output2\n - module: \"$l_mname\" is not deny listed"
            #Si NO está denegado, agrega error.
        fi
    }
    # l_mpath contiene rutas como:
    #/lib/modules/6.1.0-10-amd64/kernel/fs
    #/lib/modules/6.1.0-11-amd64/kernel/fs
    #(etc. para cada versión de kernel instalada)
    #El bucle procesa cada ruta individualmente como $l_mdir
    for l_mdir in $l_mpath; do
        if [ -d "$l_mdir/$l_mndir" ] && [ -n "$(ls -A $l_mdir/$l_mndir)" ]; then
            #[ -d ruta ] -> Verifica si existe un directorio.
            #ls -A -> Lista todos los archivos, incluso ocultos.
            #[ -n "$(ls -A $l_mdir/$l_mndir) ] -> Verifica si la variable no está vacía.
            # Verifica si el directorio del módulo existe y no está vacío.
            l_output3="$l_output3\n - \"$l_mdir\"" #Si el módulo existe, agrega esta ruta a l_output3
            [ "$l_dl" != "y" ] && module_deny_chk
            #l_dl es una bandera que inicia vacía ("")
            #En la primera iteración donde se encuentra el módulo:
                #l_dl != "y" es verdadero → Ejecuta module_deny_chk()
                #Dentro de module_deny_chk(), se establece l_dl="y"
            #En iteraciones posteriores:
                #l_dl="y" → Ya no ejecuta module_deny_chk()
            #¿Por qué solo una vez?
            #La denegación (blacklist) es una configuración global (en /etc/modprobe.d/), no depende de la versión del kernel. Solo necesitamos verificarla una vez.
            if [ "$l_mdir" = "/lib/modules/$(uname -r)/kernel/$l_mtype" ]; then
                #uname -r -> Devuelve la versión del kernel actual.
                #Compara con la ruta del kernel actualmente en uso.
                module_loadable_chk #Podría cargarse este módulo?
                module_loaded_chk #¿Está actualmente cargado en memoria?
            fi
        else
            l_output="$l_output\n - module: \"$l_mname\" doesn't exist in \"$l_mdir\""
            #Si el directorio no existe o está vacío, registra que el módulo no está presente
        fi
    done
    # Report results. If no failures output in l_output2, we pass
    [ -n "$l_output3" ] && echo -e "\n\n -- INFO --\n - module: \"$l_mname\" exists in:$l_output3"
    #[ -n "$l_output3" ]: Verifica si l_output3 no está vacía (contiene rutas donde existe el módulo)
    #Si es verdadero: Imprime información sobre dónde existe el módulo
    if [ -z "$l_output2" ]; then
    # Verifica si l_output2 está vacía (no hay errores)
        echo -e " \e[1;32;47m ** [PASS] ** \e[1;39;49m \n$l_output\n" >> "$salida"
        #Muestra contenido de l_output (configuraciones correctas)
    else
        echo -e " \e[1;31;47m ** [FAIL] ** \e[1;39;49m \n - Reason(s) for audit failure:\n$l_output2\n" >> "$salida"
        [ -n "$l_output" ] && echo -e "\n- Correctly set:\n$l_output\n" >> "$salida"
        #Como hay configuraciones correctas (l_output no vacío), las muestra
        #- Reason(s) for audit failure:
        #- módulo: "cramfs" se puede cargar: "install /bin/true"
        #- módulo: "cramfs" no está en la lista de denegación
    fi
    bash ../registrar_log.sh "$salida" "$log_auditorias.log"
}