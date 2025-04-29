export const idlFactory = ({ IDL }) => {
  const PriceResponse = IDL.Record({ 'quantity' : IDL.Nat, 'price' : IDL.Nat });
  const OrderSide = IDL.Variant({ 'Buy' : IDL.Null, 'Sell' : IDL.Null });
  const OrderPrice = IDL.Record({
    'quantity' : IDL.Variant({
      'Buy' : IDL.Tuple(IDL.Nat, IDL.Nat),
      'Sell' : IDL.Nat,
    }),
    'price' : IDL.Nat,
  });
  const Tick = IDL.Record({
    'bestAsk' : PriceResponse,
    'bestBid' : PriceResponse,
  });
  const OrderType = IDL.Variant({
    'FAK' : IDL.Null,
    'FOK' : IDL.Null,
    'LMT' : IDL.Null,
    'MKT' : IDL.Null,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  return IDL.Service({
    'clearOrderBook' : IDL.Func([], [], []),
    'depth' : IDL.Func(
        [IDL.Opt(IDL.Nat)],
        [
          IDL.Record({
            'ask' : IDL.Vec(PriceResponse),
            'bid' : IDL.Vec(PriceResponse),
          }),
        ],
        ['query'],
      ),
    'getOrder' : IDL.Func(
        [IDL.Vec(IDL.Nat8), IDL.Opt(OrderSide)],
        [IDL.Opt(OrderPrice)],
        ['query'],
      ),
    'inOrderBook' : IDL.Func([IDL.Vec(IDL.Nat8)], [IDL.Bool], ['query']),
    'level1' : IDL.Func([], [Tick], ['query']),
    'removeOrder' : IDL.Func([IDL.Vec(IDL.Nat8), IDL.Opt(OrderSide)], [], []),
    'trade' : IDL.Func(
        [IDL.Vec(IDL.Nat8), OrderSide, IDL.Nat, IDL.Nat, OrderType, IDL.Nat],
        [Result],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
