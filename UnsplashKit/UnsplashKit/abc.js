if (!this.__testjs__) {  
    __testjs__ = {};  
}  
  
__testjs__.Class1 = {  
      
hideLogo: function (str) {  
    //logo 将消失  
    var element = document.getElementById("user_email")  
    element.value = "susuyan@163.com"

    var element1 = document.getElementById("user_password")
    element1.value = "aqa69470328"
    
    document.getElementsByClassName('btn-block-level')[1].click()
    return document.title  
},  
      
      
      
      
};  
