let floors = [];
let isOpen = false;

function GetParentResourceName() {
    return window.location.hostname;
}

window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('Message reçu:', data);
    
    if (data.type === 'openElevator') {
        floors = data.floors || [];
        console.log('Floors reçus:', floors);
        generateFloorButtons();
        openElevator();
    } else if (data.type === 'closeElevator') {
        closeElevator();
    }
});

function generateFloorButtons() {
    const container = document.getElementById('floorButtons');
    
    if (!floors || floors.length === 0) {
        console.log('Utilisation des boutons statiques');
        return;
    }
    
    container.innerHTML = '';

    const floorDisplay = {
        1: { number: 'RDC', label: 'Rez-de-chaussée' },
        2: { number: '1', label: 'Premier étage' },
        3: { number: '2', label: 'Deuxième étage' },
        4: { number: '3', label: 'Troisième étage' },
        5: { number: '4', label: 'Quatrième étage' },
        6: { number: '5', label: 'Cinquième étage' }
    };

    floors.forEach(floor => {
        const button = document.createElement('button');
        button.className = 'btn';
        button.onclick = () => selectFloor(floor.id);
        
        const display = floorDisplay[floor.id] || { 
            number: floor.id.toString(), 
            label: floor.label 
        };
        
        button.innerHTML = `
            <div class="floor-number">${display.number}</div>
            <div class="floor-label">${display.label}</div>
        `;
        
        container.appendChild(button);
    });
}

function openElevator() {
    if (!isOpen) {
        isOpen = true;
        document.body.style.display = 'none';
     //   document.body.classList.add('show');
        console.log('UI ouverte');
    }
}

function closeElevator() {
    if (isOpen) {
        isOpen = false;
        document.body.classList.remove('show');
        console.log('UI fermée');
        
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).catch(() => {
            console.log('Erreur fetch closeUI - normal en développement');
        });
    }
}

function selectFloor(floorId) {
    console.log('Étage sélectionné:', floorId);
    
    fetch(`https://${GetParentResourceName()}/selectFloor`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            floorId: floorId
        })
    }).catch(() => {
        console.log('Erreur fetch selectFloor - normal en développement');
    });
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' && isOpen) {
        closeElevator();
    }
});

document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});


