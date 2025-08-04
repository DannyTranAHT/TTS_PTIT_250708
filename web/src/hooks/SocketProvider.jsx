import { createContext, useContext, useEffect, useState } from "react";
import socket from "../services/socketService";

const SocketContext = createContext();

export const SocketProvider = ({ children }) => {
  const [socketInstance, setSocketInstance] = useState(null);

  useEffect(() => {
    if (!socket.connected) {
      socket.connect();
    }
    setSocketInstance(socket);

    return () => {
      socket.disconnect();
    };
  }, []);

  return (
    <SocketContext.Provider value={socketInstance}>
      {children}
    </SocketContext.Provider>
  );
};

export const useSocket = () => useContext(SocketContext);
