exports.getEventResponse = async (txnRequest, key, eventNumber=0) => {
  const txnResponse = await txnRequest.wait();
  return txnResponse.events[eventNumber].args[key]
}

exports.echo = () => {
  console.log('hello!');
}