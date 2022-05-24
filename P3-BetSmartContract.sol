pragma solidity 0.8.14;

contract RimacProject3Bet {

    // Iznos u Wei (1 ETH = 10 ** 18 Wei) potreban za sudjelovanje u 
okladi
    uint256 public betValue;

    // Maximalan broj sudionika
    uint256 public maxParticipants = 2;

    // Pravi broj sudionika
    uint256 public participantsCount;

    // Mapping sudionika
    mapping  (uint256 => address) participants;

    // Adresa -> strana (true - znaci da ce P3 do 6mj 2025 normalno 
voziti odredenim rutama u ZG autonomno bez vozaca, false znaci da nece)
    mapping (address => bool) bets;

    // Usuglasavanje oko isplate
    mapping (uint256 => bool) settlement;

    // Counter
    uint256 public settlementCount;

    // Nakon kojeg timestampa je moguce usaglasiti se oko situacije
    uint public deadline;


    // Konstruktor :)
    constructor() {
        participantsCount = 0;
        betValue = 1460 ** 14; // 14600000000000000
        deadline = 1749990630; // 2025/06/15 12:30:30
    }

    // Funkcija za okladu
    function makeBet(bool side) public payable {
        // Vrijednost poslana u Wei potrebna za okladu mora odgovarati 
vrijednosti varijable betValue
        require(msg.value == betValue);

        // Provjera da smije biti samo 2 sudinika
        require(participantsCount < maxParticipants);

        // Dodajemo adresu s koje je pozvana funkcija kao sudionika
        participants[participantsCount] = msg.sender;

        // Povecavamo counter
        participantsCount++;
        
        // Dodajemo adresu skupa sa stranom na koju se sudionik kladi
        bets[msg.sender] = side;
    }

    // Vraca popis sudionika
    function getParticipants() public view returns (address[] memory) {
        address[] memory memoryArray = new 
address[](participantsCount);
        for(uint i = 0; i < participantsCount; i++) {
            memoryArray[i] = participants[i];
        }
        return memoryArray;
    }

    function vote(bool side) public {
        // TODO: Provjera da deadline odgovara
        require(block.timestamp > deadline);

        bool isParticipant = false;
        for(uint i = 0; i < participantsCount; i++) {
            if(participants[i] == msg.sender){
                isParticipant = true;
                break;
            }
        }
        if(isParticipant == true){
            settlement[settlementCount] = side;
        }
        settlementCount++;
    }

    function withdraw() public {
        require(settlementCount == 2, "Potrebno je da se oba sudionika 
usuglase");

        // Provjera inicijalne oklade potrazivaca isplate
        bool initialSide = bets[msg.sender];

        uint onMySideCounter = 0;

        // Ako su se obje strane usuglasile oko ishoda i na strani je 
potrazivaca - naplavi isplatu
        for(uint i = 0; i < settlementCount; i++) {
            if(settlement[i] == initialSide){
                onMySideCounter++;
            }      
        }
        if(onMySideCounter == 2){
            // Isplati potrazivacu sav iznos
            payable(msg.sender).transfer(betValue * 2);
        } else {
            // Isplati samo moj ulog
            payable(msg.sender).transfer(betValue);

        }

    }

}
