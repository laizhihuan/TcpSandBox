import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.ResourceBundle;
import java.util.Set;

public class SandBoxServer {
	private ByteBuffer sendBuffer;
	private Selector selector;
	
	public SandBoxServer(int port,String sendText) throws IOException {
		ServerSocketChannel ss = null;
		ss = ServerSocketChannel.open();
		ss.configureBlocking(false);
		ServerSocket scoket = ss.socket();
			
		scoket.bind(new InetSocketAddress(port));
			
		selector = Selector.open();
			
		ss.register(selector, SelectionKey.OP_ACCEPT);
		
		this.sendBuffer = ByteBuffer.wrap(sendText.getBytes());
		
		System.out.println("SandBoxServer start at " + port);
	}
	
	private void listen() throws IOException {
		while(true) {
			selector.select();
			Set<SelectionKey> keys = selector.selectedKeys();
			Iterator<SelectionKey> iterator = keys.iterator();
			while(iterator.hasNext()) {
				SelectionKey key = iterator.next();
				iterator.remove();
				handleKey(key);
			}
		}
	}

	private void handleKey(SelectionKey key) throws IOException {
		ServerSocketChannel server = null;
		SocketChannel client = null;
		if(key.isAcceptable()) {
			server = (ServerSocketChannel)key.channel();
			client = server.accept();
			client.configureBlocking(false);
			//写入sandbox内容
			client.write(sendBuffer);
			client.register(selector, SelectionKey.OP_READ);
			client.close();
		} 
	}
	
	public static void main(String[] args) throws IOException {
		int port = 8888;
		
		ResourceBundle rs = ResourceBundle.getBundle("configure");
		port = Integer.parseInt(rs.getString("port"));
		String sendText = rs.getString("sendText");
		
		SandBoxServer server = new SandBoxServer(port,sendText);
		server.listen();
	}
}
