#include<stdio.h>
#include<fstream>
#include<iostream>
#include<string.h>
#include<math.h>
#include<stdlib.h>

using namespace std;
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
        cout<<"Found in scopeTable #"<<id<<" at position "<<i<<","<<j<<endl;
        return res;
    }

    bool insert(string k,string t)
    {
        int index,cnt=0;

        SymbolInfo * skp;
        skp=lookup(k);
        if(skp != NULL)
        {
            cout<<"item already exist"<<endl;
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
            cout<<"Unsuccessful deletion: item not found"<<endl;
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

            cout<<"deleted entry from scopeTable# "<<id<<" at position "<<in<<","<<j<<endl;
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
        cout<<endl;
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

int main()
{
    char l[20];
    char nam[20],typ[20];
    int n;
    FILE * fp;
    fp=fopen("input1.txt","r");
    fscanf(fp,"%d",&n);
    SymbolTable s(n);

    while(!feof(fp)){

    fscanf(fp,"%s",&l);
    printf("%s",l);
    printf("  ");
    if(!strcmp(l,"I"))
    {
        fscanf(fp,"%s %s",&nam,&typ);
        cout<<nam<<"  "<<typ<<endl;
        string st(nam);
        string st1(typ);
        s.insert(st,st1);
    }

    else if(!strcmp(l,"L"))
    {
        fscanf(fp,"%s",&nam);
        SymbolInfo *skp;
        cout<<nam<<endl;
        string st(nam);
        skp=s.lookup(st);
        if(skp == NULL)
           cout<<"NOT FOUND"<<endl;
    }

    else if(!strcmp(l,"D"))
    {
        fscanf(fp,"%s",&nam);
        cout<<nam<<endl;
        string st(nam);
        s.Remove(st);

    }

    else if(!strcmp(l,"P"))
    {
        fscanf(fp,"%s",&nam);
        cout<<nam<<endl;
        //cout<<s.get_current()<<endl;
        if(!strcmp(nam,"A"))
        {
            s.print_all();
        }
        else if(!strcmp(nam,"C"))
            s.print_current();
    }
    else if(!strcmp(l,"S"))
    {
        cout<<endl;
        s.enter_scope();


    }
    else if(!strcmp(l,"E"))
    {
        cout<<endl;
        s.exit_scope();

    }


}

}


