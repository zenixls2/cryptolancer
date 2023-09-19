import "@stdlib/deploy";
import "@stdlib/ownable";

message WalletData {
    balance: Int;
    owner: Slice;
    jetton: Slice;
    jetton_wallet_code: Cell;
}

message JettonData {
    total_supply: Int;
    mintable: Int;
    admin_address: Slice;
    jetton_content: Cell;
}

fun pack_wallet_data(status: Int, balance: Int, owner: Address, master: Address, code: Cell) : Cell {
    return beginCell()
        .storeUint(status, 4)
        .storeCoins(balance)
        .storeAddress(owner)
        .storeAddress(master)
        .storeRef(code)
        .endCell();
}

fun wallet_init(owner: Address, master: Address, code: Cell): StateInit {
    let c: Cell = beginCell()
        .storeUint(0, 1+1)
        .storeRef(code)
        .endCell();
    let data: Cell = beginCell()
        .storeRef(pack_wallet_data(0, 0, owner, master, code))
        .endCell();
    return StateInit {
        code: c,
        data: data
    };
}


contract TestCoin with Deployable {
    token_type: Int as uint32; 
    unknown: Int as uint64;
    supply: Int as uint32;
    admin_address: Address;
    transfer_admin_address: Address;
    wallet_code: Cell;
    
    init(supply: Int, admin: Address, trans_admin: Address, ton_amount: Int) {
        self.token_type = 0x178d4519;
        self.unknown = 0;
        self.supply = supply;
        self.admin_address = admin;
        self.transfer_admin_address = trans_admin;
        self.wallet_code = beginCell().storeCoins(ton_amount).storeUint(0, 1).endCell();
    } 

    /*get fun get_wallet_data(): WalletData {
    }
    get fun get_jetton_data(): JettonData {
    }*/
    get fun get_wallet_address(owner_addr: Address): Address {
        let total_supply: Int = self.supply;
        let admin_addr: Address = self.admin_address;
        let trans_addr: Address = self.transfer_admin_address;
        let state_init: StateInit = wallet_init(owner_addr, myAddress(), self.wallet_code);
        return contractAddress(state_init);
    }
}
