import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";

message Record {
    employer: Address;
    employee: Address;
    tokenAddress: Address;
    value: Int;
    complete: Bool;
}

struct Ids {
    ids: map<Int, Int as uint8>;
}

contract CryptoLancer with Deployable, Resumable {
    // contract Id counter
    id: Int;
    // contract Owner
    owner: Address;
    // Resumable required field 
    stopped: Bool;
    // <contract Id, Record>
    contracts: map<Int, Record>;
    // <employee Address, Set<contractId>>
    employee_ids: map<Address, Ids>;
    // <employer Address, Set<contractId>>
    employer_ids: map<Address, Ids>;

    init(owner: Address) {
        self.owner = owner;
        self.stopped = false;
        self.id = 0;
    }

    receive(msg: Record) {
        self.requireNotStopped();
        let ctx: Context = context();
        require(ctx.sender == msg.employee || ctx.sender == self.owner, "Invalid sender");
        require(!msg.complete, "Cannot create a completed record");
        require(msg.value > 0, "Invalid value");
        // TODO: check token address exists
        // TODO: check employee balance enough

        self.contracts.set(self.id, msg);
	let ids_opt1: Ids? = self.employee_ids.get(msg.employee);
        if (ids_opt1 != null) {
            let ids: Ids = ids_opt1!!;
            ids.ids.set(self.id, 0);
        } else {
            let ids: Ids = Ids{ids: null};
            ids.ids.set(self.id, 0);
            self.employee_ids.set(msg.employee, ids);
        }
        let ids_opt2: Ids? = self.employer_ids.get(msg.employer);
        if (ids_opt2 != null) {
            let ids: Ids = ids_opt2!!;
            ids.ids.set(self.id, 0);
        } else {
            let ids: Ids = Ids{ids: null};
            ids.ids.set(self.id, 0);
            self.employer_ids.set(msg.employer, ids);
        }
        self.id  = self.id + 1;
    }

    get fun record(id: Int): Record? {
        return self.contracts.get(id);
    }

    get fun employer_ids(addr: Address): Ids? {
        let ctx: Context = context();
        require(ctx.sender == addr || ctx.sender == self.owner, "Invalid user for reading data");
        return self.employer_ids.get(addr);
    }

    get fun employee_ids(addr: Address): Ids? {
        let ctx: Context = context();
        require(ctx.sender == addr || ctx.sender == self.owner, "Invalid user for reading data");
        return self.employee_ids.get(addr);
    }

}
