module vmq

import time

fn test_timeout() {
	ctx := new_context()
	p1 := new_socket(ctx, SocketType.pair) or {
		panic(err)
	}
	p2 := new_socket(ctx, SocketType.pair) or {
		panic(err)
	}

	p1.bind('inproc://timeouttest') or {
		panic(err)
	}
	p1.set_send_timeout(time.millisecond * 100) or {
		panic(err)
	}
	p1.send('this will fail becuase no pair is connected'.bytes()) or {}

	p2.connect('inproc://timeouttest') or {
		panic(err)
	}
	p1.send("but that's ok, we set a timeout!".bytes()) or {
		panic(err)
	}

	println(p2.recv() or {
		panic(err)
	}.bytestr())
}

fn test_pubsub() {
	ctx := new_context()
	p := new_socket(ctx, SocketType.@pub) or {
		panic(err)
	}
	s := new_socket(ctx, SocketType.sub) or {
		panic(err)
	}

	p.bind('inproc://pubsubtest') or {
		panic(err)
	}
	s.connect('inproc://pubsubtest') or {
		panic(err)
	}

	s.subscribe('[topic]'.bytes()) or {
		panic(err)
	}

	p.send('[topic] hi world!'.bytes()) or {
		panic(err)
	}
	p.send('[othertopic] bye world!'.bytes()) or {
		panic(err)
	}
	p.send('[topic] hi (again)!'.bytes()) or {
		panic(err)
	}

	m1 := s.recv() or {
		panic(err)
	}
	println(m1.bytestr())

	m2 := s.recv() or {
		panic(err)
	}
	println(m2.bytestr())

	s.unsubscribe('[topic]'.bytes()) or {
		panic(err)
	}
	s.subscribe('[othertopic]'.bytes()) or {
		panic(err)
	}

	time.sleep(time.second)
	p.send('[topic] hi (again**2) or {
		panic(err)
	}'.bytes()) or {
		panic(err)
	}
	p.send('[othertopic] hey world!'.bytes()) or {
		panic(err)
	}

	m3 := s.recv() or {
		panic(err)
	}
	println(m3.bytestr())
}

fn test_pushpull() {
	ctx := new_context()
	push := new_socket(ctx, SocketType.push) or {
		panic(err)
	}
	pull := new_socket(ctx, SocketType.pull) or {
		panic(err)
	}

	// Generate some test keys
	pub_key, sec_key := curve_keypair() or {
		panic(err)
	}
	push.setup_curve(pub_key, sec_key) or {
		panic(err)
	}
	push.set_curve_server() or {
		panic(err)
	}

	pull_pk, pull_sk := curve_keypair() or {
		panic(err)
	}
	pull.setup_curve(pull_pk, pull_sk) or {
		panic(err)
	}
	pull.set_curve_serverkey(pub_key) or {
		panic(err)
	}

	push.bind('tcp://127.0.0.1:5555') or {
		panic(err)
	}
	pull.connect('tcp://127.0.0.1:5555') or {
		panic(err)
	}
	time.sleep(time.second)
	push.send('hello!'.bytes()) or {
		panic(err)
	}
	t := go recv(pull)
	t.wait()
}

fn recv(pull &Socket) {
	msg := pull.recv() or { panic(err) }
	println(msg.bytestr())
}
