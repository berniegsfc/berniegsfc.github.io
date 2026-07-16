

pro testHttpProxy
    compile_opt idl2

    proxySettings = obj_new('SpdfHttpProxy')

    print, 'authentication = ', proxySettings.getAuthentication()
    print, 'hostname = ', proxySettings.getHostname()
    print, 'password = ', proxySettings.getPassword()
    print, 'port = ', proxySettings.getPort()
    print, 'username = ', proxySettings.getUsername()
end
