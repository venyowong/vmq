# vmq

This fork support `zmq_proxy`, adjusts the directory structure, and submit it to [vpm](https://vpm.vlang.io/)

If this is not allowed, please contact me to delete this fork and [package](https://vpm.vlang.io/packages/venyowong.vmq)

V Wrapper For ZMQ

`vmq` attempts to maintain a similar API to libzmq. Typical usage is:

1. Create a context via `vmq.new_context()`
2. Create a socket via `vmq.new_socket(ctx, vmq.SocketType.@pub)`
3. Either call `sock.bind("tcp://127.0.0.1:5555")` or `sock.connect("inproc://test")` to bind or connect to some endpoint
4. Send on the socket via `sock.send([]byte)`
5. Receive from a socket via `sock.recv()` or `sock.recv_buf([]byte)`

Here's an example:

```v
import vmq

fn main() {
  ctx := vmq.new_context()
  push := vmq.new_socket(ctx, vmq.SocketType.push)!
  pull := vmq.new_socket(ctx, vmq.SocketType.pull)!
  
  push.bind("inproc://test")!
  pull.connect("inproc://test")!
  
  push.send("hello!".bytes())!
  msg := pull.recv()!

  println(string(msg))
}
```
