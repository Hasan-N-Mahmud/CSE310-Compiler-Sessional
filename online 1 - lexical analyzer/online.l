%option noyywrap
%option yylineno
%x STK
%{

#include<fstream>
#include<iostream>
#include<math.h>
#include<stdlib.h>
#include<cstdio>
#include<string.h>
#include<string>
using namespace std;

int line_count=1;
int error_count=0;
FILE *logout;
FILE *tokenout;
int global=0;
class SymbolInfo
{
private:
    string name;
    string type;

public:
    int flag=-1;
    SymbolInfo * next= NULL;
    string get_name(){return name;};
    string get_type(){return type;};
    void set_name(string str){name=str;};
    void set_type(string str){type=str;};
};


class scopeTable
{
   scopeTable * parent= NULL;
   public:

    SymbolInfo * r= NULL;
    int id= -1;
    //id++;
    int num;
    scopeTable * get_parent(){return parent;}
    void set_parent(scopeTable * s){parent=s;};

    scopeTable(int n)
    {
        r=new SymbolInfo[n];
        num=n;
    }

    int Hash(string k)
    {

         int i,j=0,l;
        char c;
        for(i=0;i<k.length();i++)
        {   c=k[i];
            j=j+c*pow(10,i);
            }
            int a=j;
    a += ~(a<<15);
    a ^=  (a>>10);
    a +=  (a<<3);
    a ^=  (a>>6);
    a += ~(a<<11);
    a ^=  (a>>16);
    a=a%num;
    return a;
    }

    SymbolInfo * lookup(string key)
    {
        int i,j=0,k;
        SymbolInfo * res=NULL;
        SymbolInfo * a=NULL;
        i=Hash(key);
        if(key == r[i].get_name())
            {
                res= &r[i];

            }
        else
        {
            if(r[i].next != NULL)
            {
                a=r[i].next;
                j++;
                while(a != NULL)
                {
                    if(a->get_name() == key)
                    {
                        res=a;
                        break;
                    }
                    else
                    {
                        a=a->next;
                        j++;
                    }
                }
            }
            else
            {
                //cout<<"Not found"<<endl;
                return res;
            }

        }
        //cout<<"Found in scopeTable #"<<id<<" at position "<<i<<","<<j<<endl;
        return res;
    }

    bool insert(string k,string t)
    {
        int index,cnt=0;

        SymbolInfo * skp;
        skp=lookup(k);
        if(skp != NULL)
        {
          //  cout<<"item already exist"<<endl;
            return false;
        }
        //cout<<k<<t<<endl;
        index = Hash(k);
        //cout<<index<<endl;
        if(r[index].flag == -1 )
        {
        r[index].set_name(k);
        r[index].set_type(t);
        r[index].flag = 3;
        }
        else if(r[index].flag != -1 && r[index].next == NULL)
        {
            SymbolInfo * r1=new SymbolInfo();

            r1->set_name(k);
            r1->set_type(t);
            r1->next=NULL;
            r[index].next=r1;
            cnt++;

        }

        else if(r[index].flag != -1 && r[index].next != NULL )
        {
           SymbolInfo * r1=new SymbolInfo();
           r1->set_name(k);
           r1->set_type(t);
           r1->next=r[index].next;
           r[index].next=r1;
            cnt++;
        }

        cout<<"Inserted in scopeTable #"<<id<<" at position "<<index<<","<<cnt<<endl;
        //print();
        return true;
    }

    void print()
    {
        SymbolInfo * q;
		
        cout<<"ScopeTable #"<<this->id<<endl;
        for(int i=0;i<num;i++)
        {
            cout<<i<<"-->  "<<"<"<<this->r[i].get_name()<<","<<this->r[i].get_type()<<"> ";
            q=this->r[i].next;
            while(q!= NULL)
            {
		
                cout<<"<"<<q->get_name()<<","<<q->get_type()<<"> ";
                q = q->next;
            }
            cout<<endl;
        }
    }

    bool Delete(string k)
    {
        SymbolInfo *sk =lookup(k);
        int j=0;
        if(sk == NULL){
           // cout<<"Unsuccessful deletion: item not found"<<endl;
            return false;
        }
        SymbolInfo * r2;
        SymbolInfo *r3;

        int in=Hash(k);

        if(r[in].get_name() == k && r[in].next == NULL)
        {
            r[in].flag = -1;
            r[in].set_name("");
            r[in].set_type("");

        }

        else if(r[in].get_name() == k && r[in].next != NULL)
        {
            r2=r[in].next;
            while(r2!= NULL)
            {
                r[in].set_name(r2->get_name());
                r[in].set_type(r2->get_type());
                r[in].next=r2->next;
                r2=r[in].next;
            }
        }

        else if(r[in].get_name() != k )
        {
            r2=r[in].next;
            j++;
            r3=&r[in];
            while(1)
            {
                if(r2->get_name() == k)
                    break;
                else{
                    r3=r2;
                    r2=r3->next;
                    j++;
                    }
            }
            if(r2->next == NULL)
            {
                r3->next = NULL;
            }
            else if(r2->next != NULL){

                r3->next=r2->next;

            }}

            //cout<<"deleted entry from scopeTable# "<<id<<" at position "<<in<<","<<j<<endl;
            return true;
            }

    ~scopeTable()
    {
        delete(r);
        delete(parent);
    }
            //end
};

class SymbolTable{

    scopeTable * current=NULL;
    int num;
public:
     int uid=0;
	SymbolTable()
{

		int n=10;
		num=10;
        //cout<<current<<endl;
        scopeTable * sc=new scopeTable(n);
        sc->id=uid;

        current=sc;
        sc=NULL;
        delete(sc);
        //cout<<current<<endl;
        //current->insert("hi","int");
        //current->print();

        uid++;


}
	
	 
    SymbolTable(int n)
    {	
        num=n;
        //cout<<current<<endl;
        scopeTable * sc=new scopeTable(n);
        sc->id=uid;

        current=sc;
        sc=NULL;
        delete(sc);
        //cout<<current<<endl;
        //current->insert("hi","int");
        //current->print();

        uid++;
    }

    scopeTable * get_current(){return current;};
    void set_current(scopeTable * s){current=s;};

    void enter_scope()
    {

        scopeTable * sc=new scopeTable(num);
        sc->id=uid;
        sc->set_parent(current);
        current=sc;
        sc=NULL;
        delete(sc);
        cout<<"New scope with id "<<uid<<" created"<<endl;
        uid++;

    }

    void exit_scope()
    {
        current = current->get_parent();
        if(current == NULL)
        {
            cout<<"exiting now"<<endl;
            exit(0);

        }

    }

    bool insert(string name,string type)
    {
        if(current !=NULL)
        {
            return current->insert(name,type);

        }
        else
        {
            cout<<"Open a scope first"<<endl;
            return false;
        }
    }

    bool Remove(string name)
    {
       return current->Delete(name);
    }

    void print_current()
    {
        current->print();
    }

    SymbolInfo * lookup(string k)
    {
        SymbolInfo * res;
        scopeTable * ex;
        res = current->lookup(k);

        ex=current->get_parent();
        while(res == NULL && ex != NULL )
        {
            res = ex->lookup(k);
            if(res != NULL){
                    //ex=NULL;
                return res;}
            ex=ex->get_parent();
        }
        //ex = NULL;
        return res;
    }

    void print_all()
    {
        current->print();
        //cout<<endl;
        scopeTable * ex=current->get_parent();
        while(ex !=NULL)
              {
                  ex->print();
                  cout<<endl;
                  ex=ex->get_parent();
              }
              //ex=NULL;
    }
};

SymbolTable st(10);

%}

WHITESPACE 	[ \t\f\r\v]+ 
LETTER 		[a-zA-Z]
INT 		[0-9]
NEWLINE		\n

FLOAT 	[0-9]*([.][0-9]+)?(E[+-]?[0-9]+)?

CHAR 	'[^\n^\\]'
CHARDIF 	'\\[ntabfv0\\r"v]'
ID 	[A-Za-z_]([A-Za-z0-9_])*


%%

{NEWLINE} {line_count++;}
			
"if"	{
			fprintf(tokenout,"<IF>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}
"else"	{
			fprintf(tokenout,"<ELSE>");
			fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
		}		
		
		
"for"	{
			fprintf(tokenout,"<FOR>");
			fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
		}


"while"	{
			fprintf(tokenout,"<WHILE>");
			fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
		}

"do"	{
			fprintf(tokenout,"<DO>");
			fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		}
"break"	{
			fprintf(tokenout,"<BREAK>");
			fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
		}

"int"	{
			fprintf(tokenout,"<INT>");
			fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
		}
"char"	{
			fprintf(tokenout,"<CHAR>");
			fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
		}
"float"	{
			fprintf(tokenout,"<FLOAT>");
			fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
		}
"double"	{
			fprintf(tokenout,"<DOUBLE>");
			fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}

"void"	{
			fprintf(tokenout,"<VOID>");
			fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
		}
"return" {
			fprintf(tokenout,"<RETURN>");
			fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
		}

"switch" {
			fprintf(tokenout,"<SWITCH>");
			fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
		}
"case"	{
			fprintf(tokenout,"<CASE>");
			fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
		}
"default"	{
			fprintf(tokenout,"<DEFAULT>");
			fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}
"continue"	{
			fprintf(tokenout,"<CONTINUE>");
			fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
		}
		

{INT}+ 	{
				fprintf(tokenout,"<CONST_INT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
				st.insert(yytext,"CONST_INT");
				st.print_all();

		}
{FLOAT}	{
				fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n\n",line_count,yytext);
				st.insert(yytext,"CONST_FLOAT");
				st.print_all();				
			}
{CHAR}	{
				
			
				fprintf(tokenout,"<CONST_CHAR,%c>",yytext[1]);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,yytext[1]);
				st.insert(yytext,"CONST_CHAR");
				st.print_all();
				
			}
{CHARDIF} {
				char c;
				
				if(yytext[2] == 'n')
				{
				c=10;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",10);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,10);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == 't')
				{
				c=9;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",9);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,9);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == '\\')
				{
				c=92;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",92);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,92);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == '\'')
				{
				c=39;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",39);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,39);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == 'a')
				{
				c=7;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",7);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,7);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == 'a')
				{
				c=7;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",7);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,7);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == 'f')
				{
				c=12;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",12);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,12);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == 'r')
				{
				c=13;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",13);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,13);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == 'b')
				{
				c=8;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",8);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,8);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == 'v')
				{
				c=11;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",11);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,11);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				else if(yytext[2] == '0')
				{
				c=0;
				string str(1,c);
				fprintf(tokenout,"<CONST_CHAR,%c>",0);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %c found\n\n",line_count,0);
				st.insert(str,"CONST_CHAR");	
				st.print_all();
						
				}
				
				
			}				
"+"|"-"	{
			fprintf(tokenout,"<ADDOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);		
			}

"*"|"/"|"%"		{
			fprintf(tokenout,"<MULOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);		
		}
		
"++"|"--"		{
			fprintf(tokenout,"<INCOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
		}	

"<"|"<="|">"|">="|"=="|"!="		{
			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);	
		}

"="		{
			fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			
		}
		
"&&"|"||"		
		{
			fprintf(tokenout,"<LOGICOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
			

		}
"&"|"|"|"^"|"<<"|">>"		
		{
			fprintf(tokenout,"<BITOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <BITOP> Lexeme %s found\n",line_count,yytext);		
			
		}

"!"		
		{
			fprintf(tokenout,"<NOT,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n",line_count,yytext);
				
		}
"("		{
			fprintf(tokenout,"<LPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
		}

")"		{
			fprintf(tokenout,"<RPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
		}
"{"		{
			fprintf(tokenout,"<LCURL,%s>",yytext);
			global=1;
			fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
		}
"}"		{
			fprintf(tokenout,"<RCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
		}

"["		{
			fprintf(tokenout,"<LTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n",line_count,yytext);
		}
"]"		{
			fprintf(tokenout,"<RTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n",line_count,yytext);
		}
","		{
			fprintf(tokenout,"<COMMA,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
		}
";"		{
			fprintf(tokenout,"<SEMICOLON,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
		}


{ID}	{
			
			fprintf(tokenout,"<ID,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n",line_count,yytext);
			st.insert(yytext,"ID");
			st.print_all();
		
		}
\"[a-zA-Z0-9\'\\ ]+\" {	
			string str(yytext);
			
			str.erase(0,1);
			str.erase(str.length()-1,1);
			
			
			int in=str.find("\\n");
			if(in>-1 && in<str.length())
			{
				char c=10;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s\n",yytext);
			}
			 in=str.find("\\t");
			if(in>-1 && in<str.length())
			{
				char c=9;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s\n",yytext);
			}
			
			in=str.find("\\b");
			if(in>-1 && in<str.length())
			{
				char c=8;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\a");
			if(in>-1 && in<str.length())
			{
				char c=7;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\v");
			if(in>-1 && in<str.length())
			{
				char c=11;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\f");
			if(in>-1 && in<str.length())
			{
				char c=12;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\0");
			if(in>-1 && in<str.length())
			{
				char c=0;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\r");
			if(in>-1 && in<str.length())
			{
				char c=13;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\'");
			if(in>-1 && in<str.length())
			{
				char c=39;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\");
			if(in>-1 && in<str.length()-1)
			{
				char c=92;
				string str2(1,c);
				str.replace(in,1,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
				
			}
			//cout<<str<<endl;
			fprintf(tokenout,"<STRING,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",line_count,yytext);
			
			}
			


\"([^\"\n]|(\\[\n])|(\"))*\" {
		int multi=0,init,k;
		init=line_count;
		string str3(yytext);
		//cout<<"MS:"<<yytext<<endl;
		str3.erase(0,1);
		str3.erase(str3.length()-1,1);
		
		int in=str3.find("\n");
		if(in>-1 && in<str3.length()){
		multi=1;
		}
		k=in;
		if(multi ==1){
		while(k>-1 && k<str3.length())
		{
		k=str3.find("\n",k+1);
		line_count++;
		}
		
		strcpy(yytext, str3.c_str());
		string str(yytext);
			
		int in=str.find("\\n");
			if(in>-1 && in<str.length())
			{
				char c=10;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s\n",yytext);
			}
			 in=str.find("\\t");
			if(in>-1 && in<str.length())
			{
				char c=9;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s\n",yytext);
			}
			
			in=str.find("\\b");
			if(in>-1 && in<str.length())
			{
				char c=8;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\a");
			if(in>-1 && in<str.length())
			{
				char c=7;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\v");
			if(in>-1 && in<str.length())
			{
				char c=11;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\f");
			if(in>-1 && in<str.length())
			{
				char c=12;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\0");
			if(in>-1 && in<str.length())
			{
				char c=0;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\r");
			if(in>-1 && in<str.length())
			{
				char c=13;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\'");
			if(in>-1 && in<str.length())
			{
				char c=39;
				string str2(1,c);
				str.replace(in,2,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
			}
			
			in=str.find("\\");
			if(in>-1 && in<str.length()-1)
			{
				char c=92;
				string str2(1,c);
				str.replace(in,1,str2);
				strcpy(yytext, str.c_str());
			//printf("string: %s",yytext);
				
			}
		fprintf(tokenout,"<STRING,%s>",yytext);
		fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",init,yytext);
}
} 
"//"((.*\\\n.*)|(.*))*  {
		int multi=0,k,init=line_count;
		string str3(yytext);
		//cout<<yytext<<endl;
		str3.erase(0,2);
		int in=str3.find("\n");
		if(in>-1 && in<str3.length()){
		multi=1;
		}
		k=in;
		if(multi ==1){
		while(k>-1 && k<str3.length())
		{
		k=str3.find("\n",k+1);
		line_count++;
		}}
		
		strcpy(yytext, str3.c_str());
		fprintf(logout,"Line no %d: <COMMENT>  %s found\n",init,yytext);
 
}

"/*"[*]*[^*]*[*]*([^*]*[*]*)"*/" {
		int multi=0,k,init=line_count;
		string str3(yytext);
		//cout<<"lkkkk:"<<yytext<<endl;
		str3.erase(0,2);
		str3.erase(str3.length()-2,2);
		int in=str3.find("\n");
		if(in>-1 && in<str3.length()){
		multi=1;
		}
		k=in;
		if(multi ==1){
		while(k>-1 && k<str3.length())
		{
		k=str3.find("\n",k+1);
		line_count++;
		}}
		
		strcpy(yytext, str3.c_str());
		fprintf(logout,"Line no %d:<COMMENT>  %s found\n",init,yytext);

}

[#](include)[<][a-z0-9_/]+[\.]+[h][>] {

		string str(yytext);
		int in=str.find("<");
		int en=str.find(">");
		cout<<en-in-1<<endl;
		str.erase(0,in);
		//str.erase(en+1,str.length()-en-1);
		strcpy(yytext,str.c_str());
		if(global==0){
		fprintf(logout,"Line no %d: TOKEN <Header File> %s included\n",line_count,yytext);}
		else
		{
		fprintf(logout,"ERROR: Line no %d: <ERROR> Global scope ERROR %s found\n",line_count,yytext);
		error_count++;
		}

}
[#](include)[<][A-Za-z0-9_/]+[\.]+[^h][>] {
		string str(yytext);
		int in=str.find("<");
		int en=str.find(">");
		cout<<en-in-1<<endl;
		str.erase(0,in);
		//str.erase(en+1,str.length()-en-1);
		strcpy(yytext,str.c_str());
		fprintf(logout,"ERROR: Line no %d: <ERROR> Invalid Header File %s found\n",line_count,yytext);
		error_count++;


}

[#](include)[<][A-Za-z0-9_/]+[\.]+[h][>] {
		string str(yytext);
		int in=str.find("<");
		int en=str.find(">");
		cout<<en-in-1<<endl;
		str.erase(0,in);
		//str.erase(en+1,str.length()-en-1);
		strcpy(yytext,str.c_str());
		fprintf(logout,"ERROR: Line no %d: <ERROR> Invalid Header File %s found\n",line_count,yytext);
		error_count++;


}

[#](include)[<][a-z0-9_/]+[\.]+[h][h]+[>] {
		string str(yytext);
		int in=str.find("<");
		int en=str.find(">");
		cout<<en-in-1<<endl;
		str.erase(0,in);
		//str.erase(en+1,str.length()-en-1);
		strcpy(yytext,str.c_str());
		fprintf(logout,"ERROR: Line no %d: <ERROR> Invalid Header File %s found\n",line_count,yytext);
		error_count++;


}

[#](include)[<][a-z0-9_/]+[\.][>] {
		string str(yytext);
		int in=str.find("<");
		int en=str.find(">");
		cout<<en-in-1<<endl;
		str.erase(0,in);
		//str.erase(en+1,str.length()-en-1);
		strcpy(yytext,str.c_str());
		fprintf(logout,"ERROR: Line no %d: <ERROR> Invalid Header File %s found\n",line_count,yytext);
		error_count++;


}

[#](include)[<]([a-z0-9_/]+[h]+)[>]|([a-z0-9_/]+[\.]+)[>] {
		string str(yytext);
		int in=str.find("<");
		int en=str.find(">");
		cout<<en-in-1<<endl;
		str.erase(0,in);
		//str.erase(en+1,str.length()-en-1);
		strcpy(yytext,str.c_str());
		fprintf(logout,"ERROR: Line no %d: <ERROR> Invalid Header File %s found\n",line_count,yytext);
		error_count++;


}
[0-9]*[\.][0-9]*([\.]+[0-9]*)* {
		fprintf(logout,"ERROR: Line no %d: <ERROR> TOO MANY DECIMAL POINT %s found\n",line_count,yytext);	
		error_count++;
}

[0-9]*([.][0-9]+)?(E[+-]?[0-9]*[\.][0-9]*) {
		fprintf(logout,"ERROR: Line no %d: <ERROR> ILL FORMED NUMBER %s found\n",line_count,yytext);
		error_count++;
}

[0-9]+([A-Za-z_]([A-Za-z0-9_])*)+ {
		fprintf(logout,"ERROR: Line no %d: <ERROR> INVALID NUMERIC CONSTANT/IDENTIFIER %s found\n",line_count,yytext);
		error_count++;
}

'[a-zA-Z0-9][a-zA-Z0-9 ]+' {
		fprintf(logout,"ERROR: Line no %d: <ERROR> MULTIPLE CHARACTER CONSTANT %s found\n",line_count,yytext);
		error_count++;
}
'[a-zA-Z0-9]|'\\'|[a-zA-Z0-9]' {
		fprintf(logout,"ERROR: Line no %d: <ERROR> INCOMPLETE CHARACTER %s found\n",line_count,yytext);
		error_count++;
}

\"([^\"\n]|(\\[\n]))* {
		int multi=0,k,init=line_count;
		string str3(yytext);
		//cout<<yytext<<endl;
		str3.erase(0,1);
		int in=str3.find("\n");
		if(in>-1 && in<str3.length()){
		multi=1;
		}
		k=in;
		if(multi ==1){
		while(k>-1 && k<str3.length())
		{
		k=str3.find("\n",k+1);
		line_count++;
		}}
		
		strcpy(yytext, str3.c_str());
		fprintf(logout,"ERROR: Line no %d: <ERROR> UNFINISHED STRING %s found\n",init,yytext);
		error_count++;
}

"/*"[*]*[^*]*[*]*([^*]*[*]*) {
		int multi=0,k,init=line_count;
		string str3(yytext);
		cout<<yytext<<endl;
		str3.erase(0,2);
		int in=str3.find("\n");
		if(in>-1 && in<str3.length()){
		multi=1;
		}
		k=in;
		if(multi ==1){
		while(k>-1 && k<str3.length())
		{
		k=str3.find("\n",k+1);
		//cout<<"done"<<endl;
		line_count++;
		}}
		
		strcpy(yytext, str3.c_str());
		fprintf(logout,"ERROR: Line no %d: <ERROR> UNFINISHED COMMENT %s found\n",init,yytext);
		error_count++;
}

[.] {
	fprintf(logout,"ERROR: Line no %d: <ERROR> UNTERMINATED CHARACTER %s found\n",line_count,yytext);
		error_count++;
}
[']['] {
	fprintf(logout,"ERROR: Line no %d: <ERROR> EMPTY CHARACTER %s found\n",line_count,yytext);
		error_count++;
}
%%

int main(int argc,char *argv[]){
	
	SymbolTable st(10);
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1605050_log.txt","w+");
	tokenout= fopen("1605050_token.txt","w+");

	yyin= fin;
	yylex();
	
	fprintf(logout,"TOTAL ERROR: %d\n",error_count);
	fprintf(logout,"TOTAL LINES: %d",line_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}