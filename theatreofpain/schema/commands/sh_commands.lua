-- By Pablo J. Martínez
nut.command.add("becomeanhero", {
	adminOnly = false,
	onRun = function( client, arguments )
		client:Kill()
    end
})