import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import OrderBook "./OrderBook"; // Correct path to your OrderBook.mo

actor Test {
    type OrderSide = OrderBook.OrderSide;
    type OrderType = OrderBook.OrderType;
    type OrderPrice = OrderBook.OrderPrice;
    type Tick = OrderBook.Tick;
    type OrderFilled = OrderBook.OrderFilled; // 🛠 add this line
    // OrderBook state (persistent)
    private stable var ic_orderBook: OrderBook.OrderBook = OrderBook.create();

    /// Trade function (MAIN ENTRY)
   public shared func trade(
    txid: Blob,
    side: OrderSide,
    quantity: Nat,
    price: Nat,
    orderType: OrderType,
    unitSize: Nat
) : async Result.Result<[OrderFilled], Text> {  // 🧠 notice the [OrderFilled] return type here!

    let incoming : OrderPrice = switch side {
        case (#Buy) { { quantity = #Buy((quantity, quantity * price / unitSize)); price = price } };
        case (#Sell) { { quantity = #Sell(quantity); price = price } };
    };

    let result = OrderBook.trade(
        ic_orderBook,
        txid,
        incoming,
        orderType,
        unitSize
    );

    ic_orderBook := result.ob;

    return #ok(result.filled);  // 🧠 now actually *return* the fills
};


    /// Get the best bid and best ask (Level 1)
    public query func level1() : async Tick {
        return OrderBook.level1(ic_orderBook);
    };

    /// Get orderbook depth (top N orders)
    public query func depth(depth: ?Nat) : async { ask: [OrderBook.PriceResponse]; bid: [OrderBook.PriceResponse] } {
        return OrderBook.depth(ic_orderBook, depth);
    };

    /// Clear the orderbook (dangerous - admin only)
    public shared func clearOrderBook() : async () {
        ic_orderBook := OrderBook.clear(ic_orderBook);
    };

    /// Check if an order is still in the book by Txid
    public query func inOrderBook(txid: Blob) : async Bool {
        return OrderBook.inOrderBook(ic_orderBook, txid);
    };

    /// Get specific order by Txid
    public query func getOrder(txid: Blob, side: ?OrderSide) : async ?OrderPrice {
        return OrderBook.get(ic_orderBook, txid, side);
    };

    /// Remove specific order by Txid
    public shared func removeOrder(txid: Blob, side: ?OrderSide) : async () {
        ic_orderBook := OrderBook.remove(ic_orderBook, txid, side);
    };



};
