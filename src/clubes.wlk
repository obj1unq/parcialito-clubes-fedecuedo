class Club{
	var property nombreClub 
	var property equipos = #{}
	var property focoInstitucion
	var property socios = #{}
	var property actividades = #{}
	var property gastoMensual
	
	method sociosDestacados(){
		return (self.capitanesDeEquipos() + self.organizadoresDeActividades()).asSet()
	}
	
	method capitanesDeEquipos(){
		return equipos.filter ({equipo => equipo.capitan()})
	}
	
	method organizadoresDeActividades(){
		return actividades.filter ({actividad => actividad.socioOrganizador()})
	}
	
	method sociosDestacadosEstrellas(){
		return (self.sociosDestacados().filter ({socio => socio.esEstrella()}) )
	}
	
	method equipoExperimentado(equipo){
		return equipo.esExpermientado()
	}
	
	method algunEquipoExperimentado(){
		return equipos.any ({equipo => self.equipoExperimentado(equipo)})
	}
	
	method actividadSocialConCincoEstrellas(){
		return actividades.any ({actividad => actividad.cantParticipantesEstrellas() >= 5})
	}
	
	method esClubPrestigioso(){
		return self.algunEquipoExperimentado() || self.actividadSocialConCincoEstrellas()
	}

	method esJugadorDestacado(jugador){
		return self.sociosDestacados().any ({socio => socio == jugador})
	}

	
	method evaluacionActividades()
	
	method evaluacion(){
		return self.evaluacionBruta() / socios.size()
	}
	
	method evaluacionBruta(){
		return focoInstitucion.evaluacion(gastoMensual, self.evaluacionActividades())
	}
	
	method sancionar(actividad){
		actividad.recibirSancion()
	}
	
	method recibirSancion(){
		if (socios.size() > 500){
			actividades.forEach ({actividad => actividad.recibirSancion()})
		}
		else { actividades.forEach ({actividad => actividad.recibirSancion()})} // error
	}
	
	method esEstrella()

}

class ClubProfesional inherits Club{
	method jugadorConMenosPartidos(jugador, valorSistema){
		return jugador.valorPase() > valorSistema
	}
	
	method evaluacion(gastoMensual, evaluacionActividades){
		return evaluacionActividades - gastoMensual
	}
}

class ClubComunitario inherits Club{
	method jugadorConMenosPartidos(jugador, valorSistema){
		return jugador.participaEnActividades() >=  true 
	}
	
	
	method evaluacion(gastoMensual, evaluacionActividades){
		return evaluacionActividades
	}
}

class ClubTradicional inherits Club{
	method jugadorConMenosPartidos(jugador, valorSistema){
		return jugador.valorPase() > 20 // valor configurable	
		//||  si participa en 3 o más actividades del club (deportivas o sociales).
	}
	
	method evaluacion(gastoMensual, evaluacionActividades){
		return (2 * evaluacionActividades) - (5 * gastoMensual)
	}
}

class Jugador inherits Club{
	var property valorPase
	var property cantPartidosDisputados
	var property valorConfigurableSistema
	
	method clubJugador(){
		return nombreClub
	}

	override method esEstrella(){
		return cantPartidosDisputados >= 50 ||
		focoInstitucion.jugadorConMenosPartidos(self, valorConfigurableSistema)
		
	}
	
	
	method participaEnActividades(){
		return actividades.sum({actividad => actividad.participaElJugador(self)})
	}
}


class Socio inherits Club{
	var antiguedad
	
	override method esEstrella(){
		return antiguedad > 20
	}
	
}


class Actividad inherits Club{
	override method evaluacionActividades(){
		return actividades.sum ({actividad => actividad.evaluar()})
	}

}


class Equipo inherits Actividad{
	var property plantel = #{}
	var property capitan
	var property cantSanciones
	var property campeonatos
	var property tipoJuego
	
	override method recibirSancion(){
		cantSanciones += 1
	}
	
	method evaluar(){
		return (self.evalCampeonatos() + self.evalPlantel() + self.evalCapitan() - (cantSanciones * 20))
	}
	
	method evalCampeonatos(){
		return 5 * campeonatos
	}
	
	method evalPlantel(){
		return plantel.size() * 2
	}
	
	method evalCapitan(){
		if (capitan.esEstrella()){
			return 5
		} else return 0
	}
	
	method participaElJugador(jugador_){
		return plantel.find ({jugador => jugador == jugador_})
	}
	
	method esExperimentado(){
		return plantel.all ({jugador => jugador.cantPartidosDisputados() >= 10})
	}
}

class EquipoFutbol inherits Equipo{
	
	override method evaluar(){
		return super() + self.estrellasDelPlantel() - (cantSanciones*10)
	}
	
	method estrellasDelPlantel(){
		return self.cantEstrellasDelPlantel() * 5
		
	}
	
	method cantEstrellasDelPlantel(){
		return plantel.sum({jugador => jugador.esEstrella()})
	}
}
class ActividadSocial inherits Actividad{
	var property socioOrganizador
	var property sociosParticipantes = #{}
	var property estaSancionada = false
	var property valorEvaluacion
	
	method evaluar(){
		if(estaSancionada){
			return 0
		} else {return valorEvaluacion}
	}

	override method recibirSancion(){
		estaSancionada = true
	}
	
	method reanudadsancion(){
		estaSancionada = false
	}
	
		method participaElJugador(jugador_){
		return socioOrganizador == jugador_ || sociosParticipantes.find ({jugador => jugador == jugador_})
	}
	
	method cantParticipantesEstrellas(){
		return sociosParticipantes.sum ({socio => socio.esEstrella()})
		}
	
}