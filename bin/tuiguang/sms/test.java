//�����Ƽ����޹�˾
import java.lang.*;
import montnets.*;
public class test
{
    public static void main(String args[])
    {

	System.out.println("argv[0]="+args[0]);
	System.out.println("argv[1]="+args[1]);
	System.out.println("argv[2]="+args[2]);
	
	mondem Mytest =new mondem();  //����һ�� mondem ���� �������������֧��64���˿ڷ���
	int rc;
	String[] wapResult=new String[3];
	
	rc=Mytest.SetThreadMode(1);   //�����߳�ģʽ
	if(rc==0){
	    System.out.println("�����߳�ģʽ�ɹ�");
	} else {
	    System.out.println("�����߳�ģʽʧ��");
	    return;
	}

	//ȫ�����óɵ���è��ʽ
	Mytest.SetModemType(0,0);
	Mytest.SetModemType(1,0);
	Mytest.SetModemType(2,0);
	Mytest.SetModemType(3,0);
	Mytest.SetModemType(4,0);
	Mytest.SetModemType(5,0);
	Mytest.SetModemType(6,0);
	Mytest.SetModemType(7,0);
	
	if((rc=(Mytest.InitModem(-1)))==0)//��ʼ������è
	{
	    System.out.println("��ʼ���ɹ�");
	    
	    //--------��ͨ���Ų���-------------
	  // rc=Mytest.SendMsg(-1,"13788907003","������Ϣ����ϲ����!");  //����һ����Ϣ,�ӿ���ʹ�õ�����˿�
	  rc=Mytest.SendMsg(-1,args[0],args[1]+","+args[2]+","+args[3]);  //����һ����Ϣ,�ӿ���ʹ�õ�����˿�
	    //rc=Mytest.SendMsg(0,"13691000000","������Ϣ����ϲ����!"); //����һ����Ϣ,ָ����һ���˿�
	    //rc=Mytest.SendMsg(1,"13691000000","������Ϣ����ϲ����!"); //����һ����Ϣ,�ƶ��ڶ����˿�
	    
	    //--Wap Push ����------------------------
	    //wapResult=Mytest.WapPushCvt("������վ����", "http://wap.mbook.cn"); //����Push����
	    //rc=Mytest.SendMsg(-1,"13691000000,001,2,123321,1,0",wapResult[1]);  //����push��Ϣ
	    
	    if(rc>=0){
		System.out.println("�ύ�ɹ�, rc="+rc);
		
		while(true) //ѭ���ȴ����ͳɹ�,����ʾ������Ϣ, Ctrl-C �˳�ѭ��
		{
		   String [] s = Mytest.ReadMsgEx(-1);
		   if(s[0].equals("-1")) {
		   	System.out.println("-����Ϣ-----");
		   } else {
		   	System.out.println(s[0]);
		   	System.out.println(s[1]);
		   	System.out.println(s[2]);
			break;
		   }
		   System.out.println("...."+    //��ʾ�����˿ڵ�״̬
		   	Mytest.GetStatus(0)+","+
		   	Mytest.GetStatus(1)+","+
		   	Mytest.GetStatus(2)+","+
		   	Mytest.GetStatus(3)+","+
		   	Mytest.GetStatus(4)+","+
		   	Mytest.GetStatus(5)+","+
		   	Mytest.GetStatus(6)+","+
		   	Mytest.GetStatus(7)+
		   	"...."
		   	);
		   try{Thread.sleep(5000);}catch(InterruptedException e){} //��ʱ�ȴ�
		}
		
	    } else {
		System.out.println("�ύ����, rc="+rc);
	    }
	} else {
	    System.out.println("��ʼ������!"+rc);
	}   
    }
}
