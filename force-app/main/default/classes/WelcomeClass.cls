/* 

Author : Sayak Haldar
Date : 30-03-2022
Description : Simple Program for Apex Rest Services
URL : https://persistentsystems21-dev-ed.lightning.force.com/services/apexrest/v1/WelcomeClass

*/

@RestResource(urlMapping='/v1/WelcomeClass/*')
global with sharing class WelcomeClass {

    global final static String WELCOME_MESSAGE = 'Welcome Sayak to Integration Course';

    @httpGet
    global static String greetMessage(){
        return WELCOME_MESSAGE;
    }

    @httpPost
    global static String postGreetMessage(){
        return WELCOME_MESSAGE+' Post';
    }

    @httpPatch
    global static String patchGreetMessage(){
        return WELCOME_MESSAGE+ ' Patch';
    }

    
}
