import UIKit
import SocketIO

class ViewController: UIViewController {
    lazy var statusLabel: UILabel = {
        return self.makeStatusLabel()
    }()
    lazy var game: Game = {
        return Game()
    }()
    lazy var presenter: GamePresenter = {
        return GamePresenter()
    }()
    
    var socket: SocketIOClient?
    var player: Player?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkGray
        
        let gridView = GridView(frame: CGRect(x: 0, y: 200, width: self.view.frame.size.width, height: self.view.frame.size.width), board: game.getBoard())
        self.view.addSubview(gridView)
        
        gridView.tapResponder = { (col, row) in
            self.respondToTap(col, row: row)
        }
        
        self.view.addSubview(statusLabel)
        
        statusLabel.text = presenter.getPlayerStatus(game.whoseTurn())
        statusLabel.textColor = UIColor.white
        statusLabel.textAlignment = NSTextAlignment.center
        
        socket = SocketIOClient(socketURL: NSURL(string:"http://140.129.13.122:3001")! as URL)
        addHandler()
        socket?.connect()
        socket?.emit("hello")
    }

    
    func respondToTap(_ col: Int, row: Int) {
        //let tappingPlayer = game.whoseTurn()
        let tappingPlayer = player
        game.setPlayer(player!)
        _ = game.takeTurn(col, row)
        if game.getRules().isWin(game.getBoard(), tappingPlayer!) {
            let a: UIAlertController = UIAlertController(title: "You Won", message: presenter.getWinStatus(tappingPlayer!), preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default)
            a.addAction(okAction)
            self.present(a, animated: true, completion: nil)
            // statusLabel.text = presenter.getWinStatus(tappingPlayer)
        }
        else {
            statusLabel.text = presenter.getPlayerStatus(game.whoseTurn())
        }
    }
    
    func makeStatusLabel() -> UILabel {
        let labelWidth: CGFloat = 100.0
        return UILabel(frame: CGRect(x: (view.frame.width - labelWidth) / 2.0, y: 100,width: labelWidth, height: 25))
    }
    
    func addHandler(){
        print(socket ?? "No Conneection")
        socket?.on("whoami") {[weak self] data, ack in
            let im = data[0] as! Bool
            if im {
                self?.player = Player.white
            }
            else {
                self?.player = Player.black
            }
        }
        
        socket?.on("playgame") {[weak self] data, ack in
            let x = data[0] as! Int
            let y = data[1] as! Int
            self?.takeTure(x, y)
        }
        
        socket?.on("win") {[weak self] data, ack in
            self?.lose()
        }
    }
    
    func takeTure(_ col:Int, _ row:Int) {
        //let tappingPlayer = other(player)
        _ = game.takeTurn(col, row)
    }
    
    func other(_ player: Player) -> Player {
        return player == Player.white ? Player.black : Player.white
    }
    
    func lose() {
        let a: UIAlertController = UIAlertController(title: "You Lose", message: presenter.getWinStatus(other(player!)), preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default)
        a.addAction(okAction)
        self.present(a, animated: true, completion: nil)
    }
}

