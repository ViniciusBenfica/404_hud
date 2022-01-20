var animacaoAcontecerUmaVez = true

var farolCarro = -1;
var seta = -1;
var cinto = -1;
var distancia = -1;
var carroTrancado = -1;

window.addEventListener("message", function (event) {
    var { 
        abrir, 
        dentroDoCarro, 
        vida, 
        colete, 
        street, 
        gasolina, 
        kmh, 
        farol, 
        setas, 
        cinto, 
        lockedCar, 
        horas,
        minutos,
        fome,
        sede,
        tokovoip,
        action
    } = event.data


    if (action == 'movie') {
        if ($(".movie-top").height() < 10) {
            $(".container").fadeOut(200)
            $(".movie-top").css({ "height": "10%", "transition": "all 1s" })
            $(".movie-bottom").css({ "height": "10%", "transition": "all 1s" })
        } else {
            $(".movie-top").css({ "height": "0%", "transition": "all 0.5s" })
            $(".movie-bottom").css({ "height": "0%", "transition": "all 0.5s" })
            setTimeout(() => {
                $(".container").fadeIn(100)
            },500)
        }
    }

    if (action == "abrirFechar"){
        $(".container").is(":visible") ? $(".container").fadeOut() : $(".container").fadeIn()
    }

    if(abrir){
        $(".container").show()
    }
    
    if (horas <= 9) horas = "0" + horas;
    if (minutos <= 9) minutos = "0" + minutos;
    $(".hour").html(`<img style="margin-left: 5px; margin-bottom: -2px;" width="15px" src="images/relogio.png"><b>${horas}:${minutos}</b>` );


    $("#color-vida").html(`
        <stop id="fome" offset=${vida || 0}% style="stop-color:rgb(255, 255, 255);stop-opacity:1" />
        <stop offset="0%" style="stop-color:rgba(255, 255, 255, 0.425);stop-opacity:1" />
    `)

    $("#color-colete").html(`
        <stop id="colete" offset=${colete || 0}% style="stop-color:rgb(255, 255, 255);stop-opacity:1" />
        <stop offset="0%" style="stop-color:rgba(255, 255, 255, 0.425);stop-opacity:1" />
    `)

    $("#color-fome").html(`
        <stop id="fome" offset=${fome || 0}% style="stop-color:rgb(255, 255, 255);stop-opacity:1" />
        <stop offset="0%" style="stop-color:rgba(255, 255, 255, 0.425);stop-opacity:1" />
    `)

    $("#color-sede").html(`
        <stop id="sede" offset=${sede || 0}% style="stop-color:rgb(255, 255, 255);stop-opacity:1" />
        <stop offset="0%" style="stop-color:rgba(255, 255, 255, 0.425);stop-opacity:1" />
    `)

    tokovoip = tokovoip * 33.3

    $("#color-tokovoip").html(`
        <stop id="tokovoip" offset=${tokovoip || 0}% style="stop-color:rgb(255, 255, 255);stop-opacity:1" />
        <stop offset="0%" style="stop-color:rgba(255, 255, 255, 0.425);stop-opacity:1" />
    `)

    if(cinto == "on"){
        $(".belt").html(`<img width="25px" src="images/com_cinto.png">`)
    }else if(cinto == "off"){
        $(".belt").html(`<img width="25px" src="images/sem_cinto.png">`)
    }
    if (dentroDoCarro){
        
        $(".hour").css("right", "5px")
        if (farol != farolCarro && farol == 1){
            $(".headlight").html(`<img width="25px" src="images/farol_baixo.png">`)
        }else if(farol != farolCarro && farol == 2){
            $(".headlight").html(`<img width="25px" src="images/farol_medio.png">`)
        }else if(farol != farolCarro && farol == 3){
            $(".headlight").html(`<img width="25px" src="images/farol_alto.png">`)
        }

        farolCarro = farol

        if(seta == 32){
        }else if(setas != seta && setas == 0){
            $(".arrow").html(`<img width="25px" src="images/setas.png">`)
        }else if(setas != seta && setas == 1){
            $(".arrow").html(`<img width="25px" src="images/seta_esquerda.png">`)
        }else if(setas != seta && setas == 2){
            $(".arrow").html(`<img width="25px" src="images/seta_direita.png">`)
        }else if(setas != seta && setas == 3){
            $(".arrow").html(`<img width="25px" src="images/pisca_alerta.png">`)
        }

        seta = setas

        if(lockedCar != carroTrancado && lockedCar == 1){
            $(".doors").html(`<img width="25px" src="images/destrancado.png">`)
        }else if (lockedCar != carroTrancado && lockedCar == 2){
            $(".doors").html(`<img width="25px" src="images/trancado.png">`)
        }

        carroTrancado = lockedCar

        $(".street-name b").text(street)
        $(".bar-gasoline").css("height", gasolina.toFixed(0)+"%")
        $(".bar-gasoline").css('background-color',`hsl(${gasolina.toFixed(0)}, 100%, 50%)`)
        $(".velocity b").text(kmh.toFixed(0))

        distancia =  $(".street-name").width() + 10

        if (animacaoAcontecerUmaVez == dentroDoCarro){
            $(".in-car").css("border", "solid 2px #fff")
            $(".street-name").css("border", "solid 2px #fff")
            $(".in-car").fadeIn(100)
            $(".street-name").fadeIn(1500)
            $(".in-car").animate({height: "50px"},900)
            $(".hour").animate({right: $(".street-name").width() + 10},{duration: 1000, })
            animacaoAcontecerUmaVez = !dentroDoCarro
        }

        $(".hour").css("position", "absolute").css("right", $(".street-name").width() + 10)

    }else{
        if (animacaoAcontecerUmaVez == dentroDoCarro){
            if(distancia == 0){
            }else{
                $(".hour").animate({right: "5px"},1000)
                $(function () {
                    $(".in-car").animate({
                        height: '0'
                    }, { duration: 1000, queue: false });
                
                    $(".in-car").fadeOut(600)
                });
    
                $(".street-name").fadeOut(600)
            }
            animacaoAcontecerUmaVez = !dentroDoCarro
        }
    }
});