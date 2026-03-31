I'll complete the WhatsApp Clone with all remaining frontend components, WebRTC calling, and deployment instructions.

🛠️ Complete Frontend Implementation (Continued)

client/src/context/ChatContext.js (Complete):

// ... (previous code continues)  
    
  return (  
    <ChatContext.Provider value={value}>  
      {children}  
    </ChatContext.Provider>  
  );  
};  
  
export const useChat = () => useContext(ChatContext);

client/src/App.js:

import React from 'react';  
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';  
import { AuthProvider, useAuth } from './context/AuthContext';  
import { ChatProvider } from './context/ChatContext';  
import Login from './pages/Login';  
import Register from './pages/Register';  
import ChatApp from './pages/ChatApp';  
import { Toaster } from 'react-hot-toast';  
  
function AppContent() {  
  const { user, loading } = useAuth();  
  
  if (loading) {  
    return (  
      <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-green-500 to-green-600">  
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white"></div>  
      </div>  
    );  
  }  
  
  return (  
    <Router>  
      <Routes>  
        <Route path="/login" element={!user ? <Login /> : <Navigate to="/" />} />  
        <Route path="/register" element={!user ? <Register /> : <Navigate to="/" />} />  
        <Route path="/" element={user ? <ChatApp /> : <Navigate to="/login" />} />  
        <Route path="*" element={<Navigate to={user ? "/" : "/login"} />} />  
      </Routes>  
      <Toaster position="top-right" toastOptions={{ duration: 4000 }} />  
    </Router>  
  );  
}  
  
function App() {  
  return (  
    <AuthProvider>  
      <ChatProvider>  
        <AppContent />  
      </ChatProvider>  
    </AuthProvider>  
  );  
}  
  
export default App;

client/src/pages/Login.js:

import React, { useState } from 'react';  
import { useAuth } from '../context/AuthContext';  
import { Link, useNavigate } from 'react-router-dom';  
import { toast } from 'react-hot-toast';  
import { Phone, Mail, Lock } from 'lucide-react';  
  
const Login = () => {  
  const [formData, setFormData] = useState({ email: '', password: '' });  
  const [isLogin, setIsLogin] = useState(true);  
  const { login, register } = useAuth();  
  const navigate = useNavigate();  
  
  const handleSubmit = async (e) => {  
    e.preventDefault();  
    try {  
      if (isLogin) {  
        await login(formData);  
      } else {  
        await register(formData);  
      }  
      navigate('/');  
    } catch (error) {  
      toast.error(error);  
    }  
  };  
  
  return (  
    <div className="min-h-screen bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center p-4">  
      <div className="bg-white/10 backdrop-blur-xl rounded-3xl p-8 w-full max-w-md shadow-2xl border border-white/20">  
        <div className="text-center mb-8">  
          <div className="w-20 h-20 bg-white/20 rounded-full flex items-center justify-center mx-auto mb-4">  
            <Phone className="w-10 h-10 text-white" />  
          </div>  
          <h1 className="text-3xl font-bold bg-gradient-to-r from-white to-gray-200 bg-clip-text text-transparent">  
            WhatsApp Clone  
          </h1>  
          <p className="text-white/80 mt-2">{isLogin ? 'Sign in to your account' : 'Create your account'}</p>  
        </div>  
  
        <form onSubmit={handleSubmit} className="space-y-6">  
          {!isLogin && (  
            <div>  
              <label className="block text-sm font-medium text-white/90 mb-2">Username</label>  
              <div className="relative">  
                <input  
                  type="text"  
                  placeholder="Enter username"  
                  className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/60 focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all"  
                  value={formData.username || ''}  
                  onChange={(e) => setFormData({ ...formData, username: e.target.value })}  
                  required={!isLogin}  
                />  
              </div>  
            </div>  
          )}  
            
          <div>  
            <label className="block text-sm font-medium text-white/90 mb-2">Email</label>  
            <div className="relative">  
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-white/60" />  
              <input  
                type="email"  
                placeholder="Enter email"  
                className="w-full pl-10 px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/60 focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all"  
                value={formData.email}  
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}  
                required  
              />  
            </div>  
          </div>  
  
          <div>  
            <label className="block text-sm font-medium text-white/90 mb-2">Password</label>  
            <div className="relative">  
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-white/60" />  
              <input  
                type="password"  
                placeholder="Enter password"  
                className="w-full pl-10 px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/60 focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all"  
                value={formData.password}  
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}  
                required  
              />  
            </div>  
          </div>  
  
          <button  
            type="submit"  
            className="w-full bg-green-500 hover:bg-green-600 text-white font-semibold py-3 px-4 rounded-xl transition-all duration-200 transform hover:scale-[1.02] active:scale-[0.98] shadow-lg"  
          >  
            {isLogin ? 'Sign In' : 'Sign Up'}  
          </button>  
        </form>  
  
        <div className="mt-8 text-center">  
          <button  
            onClick={() => setIsLogin(!isLogin)}  
            className="text-green-200 hover:text-white font-medium transition-colors"  
          >  
            {isLogin ? 'Create new account' : 'Already have an account? Sign in'}  
          </button>  
        </div>  
  
        <div className="mt-8 pt-8 border-t border-white/20 text-xs text-white/50 text-center">  
          <p>By continuing, you agree to our Terms of Service and Privacy Policy</p>  
        </div>  
      </div>  
    </div>  
  );  
};  
  
export default Login;

client/src/pages/ChatApp.js (Main WhatsApp Interface):

import React, { useState, useEffect, useRef, useCallback } from 'react';  
import { useAuth } from '../context/AuthContext';  
import { useChat } from '../context/ChatContext';  
import ContactsSidebar from '../components/ContactsSidebar';  
import ChatWindow from '../components/ChatWindow';  
import CallControls from '../components/CallControls';  
  
const ChatApp = () => {  
  const { user } = useAuth();  
  const { currentChat, onlineUsers, socket } = useChat();  
  const [showSidebar, setShowSidebar] = useState(false);  
  const [searchTerm, setSearchTerm] = useState('');  
  
  const containerRef = useRef(null);  
  
  // Join socket room when user logs in  
  useEffect(() => {  
    if (user && socket) {  
      socket.emit('join', user.id);  
        
      return () => {  
        socket.emit('leave', user.id);  
      };  
    }  
  }, [user, socket]);  
  
  return (  
    <div className="h-screen flex flex-col bg-[#0f0f23] overflow-hidden">  
      {/* Top Bar */}  
      <div className="h-16 bg-[#202c33] border-b border-[#2a3942] flex items-center px-6">  
        <button  
          className="p-2 -ml-1 rounded-lg hover:bg-[#17212b] lg:hidden"  
          onClick={() => setShowSidebar(true)}  
        >  
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">  
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />  
          </svg>  
        </button>  
          
        <div className="flex items-center space-x-4 ml-4">  
          <img  
            src={`https://ui-avatars.com/api/?name=${user.username}&background=25D366&color=fff&size=40`}  
            alt={user.username}  
            className="w-10 h-10 rounded-full"  
          />  
          <div>  
            <p className="font-semibold text-white">{user.username}</p>  
            <p className="text-xs text-green-400">Online</p>  
          </div>  
        </div>  
      </div>  
  
      {/* Main Content */}  
      <div className="flex-1 flex overflow-hidden relative">  
        {/* Sidebar */}  
        <div   
          className={`lg:w-80 bg-[#111b21] border-r border-[#2a3942] transition-transform duration-300 ${  
            showSidebar ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'  
          }`}  
          ref={containerRef}  
        >  
          <ContactsSidebar searchTerm={searchTerm} setSearchTerm={setSearchTerm} />  
        </div>  
  
        {/* Overlay for mobile */}  
        {showSidebar && (  
          <div   
            className="fixed inset-0 bg-black/50 z-20 lg:hidden"  
            onClick={() => setShowSidebar(false)}  
          />  
        )}  
  
        {/* Chat Window */}  
        <div className="flex-1 flex flex-col">  
          {currentChat ? (  
            <ChatWindow />  
          ) : (  
            <div className="flex-1 flex items-center justify-center bg-gradient-to-br from-[#0f0f23] to-[#111b21]">  
              <div className="text-center">  
                <div className="w-24 h-24 bg-white/10 rounded-full flex items-center justify-center mx-auto mb-6">  
                  <svg className="w-12 h-12 text-white/50" fill="none" stroke="currentColor" viewBox="0 0 24 24">  
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />  
                  </svg>  
                </div>  
                <h3 className="text-xl font-semibold text-white/80 mb-2">WhatsApp Clone</h3>  
                <p className="text-white/50 max-w-sm mx-auto">  
                  Send and receive messages without keeping your phone online.  
                </p>  
              </div>  
            </div>  
          )}  
        </div>  
      </div>  
  
      {/* Call Controls Overlay */}  
      <CallControls />  
    </div>  
  );  
};  
  
export default ChatApp;

client/src/components/ContactsSidebar.js:

import React, { useState, useEffect } from 'react';  
import { useAuth } from '../context/AuthContext';  
import { useChat } from '../context/ChatContext';  
import axios from 'axios';  
import { Search, UserPlus } from 'lucide-react';  
  
const ContactsSidebar = ({ searchTerm, setSearchTerm }) => {  
  const { user } = useAuth();  
  const { setCurrentChat, onlineUsers } = useChat();  
  const [users, setUsers] = useState([]);  
  const [loading, setLoading] = useState(false);  
  
  const searchUsers = async (query) => {  
    if (query.length < 2) {  
      setUsers([]);  
      return;  
    }  
      
    setLoading(true);  
    try {  
      const { data } = await axios.get(`${process.env.REACT_APP_API_URL}/users?q=${query}`);  
      setUsers(data);  
    } catch (error) {  
      console.error('Error searching users:', error);  
    } finally {  
      setLoading(false);  
    }  
  };  
  
  useEffect(() => {  
    const timeoutId = setTimeout(() => {  
      searchUsers(searchTerm);  
    }, 300);  
  
    return () => clearTimeout(timeoutId);  
  }, [searchTerm]);  
  
  return (  
    <>  
      {/* Header */}  
      <div className="p-4 border-b border-[#2a3942]">  
        <div className="relative">  
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />  
          <input  
            type="text"  
            placeholder="Search or start new chat"  
            className="w-full pl-10 pr-4 py-3 bg-[#202c33] border border-[#405d70] rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent"  
            value={searchTerm}  
            onChange={(e) => setSearchTerm(e.target.value)}  
          />  
        </div>  
      </div>  
  
      {/* Contacts List */}  
      <div className="flex-1 overflow-y-auto">  
        {loading ? (  
          <div className="p-8 text-center text-gray-400">Searching...</div>  
        ) : users.length > 0 ? (  
          users.map((contact) => (  
            <div  
              key={contact._id}  
              className="flex items-center p-4 hover:bg-[#202c33] cursor-pointer border-b border-[#2a3942] last:border-b-0 transition-colors"  
              onClick={() => {  
                setCurrentChat(contact);  
                setSearchTerm('');  
              }}  
            >  
              <img  
                src={`https://ui-avatars.com/api/?name=${contact.username}&background=${contact.isOnline ? '25D366' : '919EAB'}&color=fff&size=48`}  
                alt={contact.username}  
                className="w-12 h-12 rounded-full"  
              />  
              <div className="ml-4 flex-1 min-w-0">  
                <div className="flex items-center justify-between">  
                  <p className="font-semibold text-white truncate">{contact.username}</p>  
                  {contact.isOnline && (  
                    <div className="w-2 h-2 bg-green-400 rounded-full"></div>  
                  )}  
                </div>  
                <p className="text-sm text-gray-400 truncate">{contact.email}</p>  
              </div>  
            </div>  
          ))  
        ) : searchTerm.length >= 2 ? (  
          <div className="p-8 text-center text-gray-400">  
            <p>No users found</p>  
          </div>  
        ) : (  
          <div className="p-8 text-center text-gray-400">  
            <UserPlus className="w-12 h-12 mx-auto mb-4 opacity-50" />  
            <p>Search for someone to start chat</p>  
          </div>  
        )}  
      </div>  
    </>  
  );  
};  
  
export default ContactsSidebar;

client/src/components/ChatWindow.js:

import React, { useState, useEffect, useRef, useCallback } from 'react';  
import { useAuth } from '../context/AuthContext';  
import { useChat } from '../context/ChatContext';  
import axios from 'axios';  
import { Phone, Video, Paperclip, Smile, Mic } from 'lucide-react';  
import { motion, AnimatePresence } from 'framer-motion';  
  
const ChatWindow = () => {  
  const { user } = useAuth();  
  const {   
    currentChat,   
    messages,   
    setMessages,   
    onlineUsers,   
    socket,   
    typing,   
    sendMessage,  
    startTyping,  
    stopTyping   
  } = useChat();  
  const [newMessage, setNewMessage] = useState('');  
  const [files, setFiles] = useState([]);  
  const messagesEndRef = useRef(null);  
  const fileInputRef = useRef(null);  
  
  // Load messages when currentChat changes  
  useEffect(() => {  
    if (currentChat?._id) {  
      const loadMessages = async () => {  
        try {  
          const { data } = await axios.get(  
            `${process.env.REACT_APP_API_URL}/messages/${currentChat._id}`  
          );  
          setMessages(data);  
        } catch (error) {  
          console.error('Error loading messages:', error);  
        }  
      };  
      loadMessages();  
    }  
  }, [currentChat, setMessages]);  
  
  // Auto-scroll to bottom  
  const scrollToBottom = useCallback(() => {  
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });  
  }, []);  
  
  useEffect(() => {  
    scrollToBottom();  
  }, [messages, scrollToBottom]);  
  
  // Socket event listeners  
  useEffect(() => {  
    if (!socket) return;  
  
    const handleReceiveMessage = (message) => {  
      if (  
        message.sender._id === currentChat?._id ||  
        message.receiver._id === currentChat?._id  
      ) {  
        setMessages(prev => [...prev, message]);  
      }  
    };  
  
    const handleTyping = ({ userId, isTyping }) => {  
      if (userId === currentChat?._id) {  
        // Update typing state  
      }  
    };  
  
    socket.on('receiveMessage', handleReceiveMessage);  
    socket.on('typing', handleTyping);  
  
    return () => {  
      socket.off('receiveMessage', handleReceiveMessage);  
      socket.off('typing', handleTyping);  
    };  
  }, [currentChat, socket, setMessages]);  
  
  const handleSendMessage = (e) => {  
    e.preventDefault();  
    if (!newMessage.trim() || !currentChat) return;  
  
    sendMessage({  
      chatId: `${user.id}-${currentChat._id}`,  
      receiverId: currentChat._id,  
      content: newMessage.trim(),
